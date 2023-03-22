module main

import db.sqlite
import vweb
import json

struct App {
	vweb.Context
pub mut:
	db sqlite.DB
}

struct Err {
	error   bool
	message string
}

fn main() {
	app := App{
		db: sqlite.connect(':memory:') or { panic(err) }
	}

	sql app.db {
		create table Article
	}

	article := Article{
		title: 'Hello, World!'
		text: 'V is great.'
	}

	sql app.db {
		insert article into Article
	}

	vweb.run(app, 8080)
}

['/'; get]
pub fn (mut app App) list_articles() vweb.Result {
	articles := app.find_all_articles()
	return app.json(articles)
}

['/'; post]
pub fn (mut app App) create_article() vweb.Result {
	article := json.decode(Article, app.req.data) or {
		app.set_status(422, '')
		return app.json(Err{
			error: true
			message: 'Could not decode article'
		})
	}

	sql app.db {
		insert article into Article
	}

	return app.json(article)
}
