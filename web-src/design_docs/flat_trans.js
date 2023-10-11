const flat_trans_version = 1;

var flat_trans_dd =  {
  _id: '_design/flat_trans',
  version: flat_trans_version,
  views: {
    simple: {
      map: function (doc) {
        if (doc.doctype == 'translation' && doc.deleted != true) {
          if (doc.content.traducciones && doc.content.traducciones.length > 0) {
            doc.content.traducciones.forEach(function (trad) {
              emit(doc.content.source_text, trad.traduccion);
            });
          } else {
            emit(doc.content.source_text, "");
          }
        }
      }.toString()
    }
  }
};

export { flat_trans_dd };
