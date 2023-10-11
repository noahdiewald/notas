const proto_version = 3
const proto_id = '_design/proto'

const proto_dd =  {
  _id: proto_id,
  version: proto_version,
  views: {
    simple: {
      map: function (doc) {
        if (doc.doctype == 'protocol' && doc.deleted != true) {
          if (doc.content.name) {
            emit(doc.content.name, doc.content.description)
          }
        }
      }.toString()
    },
    responses : {
      map: function (doc) {
        if (doc.doctype == 'response' && doc.deleted != true) {
          if (doc.content.protoid && doc.content.arows) {
            emit(doc.content.protoid, doc.content.arows)
          }
        }
      }.toString()
    }
  }
}

export { proto_dd }
