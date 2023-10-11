const upsert_dd = (dd, database) => {
  database.get(dd._id).then((doc) => {
    if (doc.version != dd.version) {
      dd._rev = doc._rev;
      
      database.put(dd).then(() => {
        // success!
      }).catch((err) => {
        // some error (maybe a 409, because it already exists?)
      });
    }
  }).catch((err) => {
    if (err.status == 404) {
      database.put(dd).then(() => {
        // success!
      }).catch((err) => {
        // some error (maybe a 409, because it already exists?)
      });
    } else {
      console.log(err);
    }
  });
}

export { upsert_dd }
