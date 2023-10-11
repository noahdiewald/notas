import '@picocss/pico'
import { init } from '@neutralinojs/lib'
import { Elm } from '../src/Main.elm'
// Design doc helper functions
import { upsert_dd } from './db.js'
// Design docs
import { trans_dd } from './design_docs/trans.js'
import { proto_dd } from './design_docs/proto.js'
// Libraries used for database access and data manipulation.
import PouchDB from 'pouchdb'

init()

// Initialize the local database
const localDB = new PouchDB('notasdb')

// Loading saved config and possibly creating new config if none is
// saved.
var conf = localStorage.getItem('notas_config')
  
if (typeof conf !== 'string') {
  conf = JSON.stringify({databases: []})
}

// Initialize Elm at the node with id root. Send the save config in
// the flags property.
const app = Elm.Main.init({ node: document.getElementById('root'),
                            flags: conf
                          })

// update or insert design documents
upsert_dd(trans_dd, localDB)
upsert_dd(proto_dd, localDB)

// Initialize live commits and report status of non-live commits.

// A port to receive changes to the config and save them. The config
// should be a JSON string.
app.ports.saveConfig.subscribe((config) => {
  localStorage.setItem('notas_config', config)
})
