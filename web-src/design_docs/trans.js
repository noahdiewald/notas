const trans_version = 1;
const trans_id = '_design/trans';

var trans_dd =  {
  _id: trans_id,
  version: trans_version,
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

export { trans_dd };
