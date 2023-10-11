const notes_version = 1;
const notes_id = '_design/notes';

var notes_dd =  {
  _id: notes_id,
  version: notes_version,
  views: {
    all: {
      map: function (doc) {
        if (doc.doctype == 'fieldnote' && doc.deleted != true) {
          emit(doc.args[0], doc.args);
        }
      }.toString()
    }
  }
};

export { notes_dd };
