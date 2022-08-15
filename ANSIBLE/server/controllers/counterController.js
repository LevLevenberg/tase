const Counter = require("../models/counter");

module.exports = {

  increment: async (req, res, next) => {
    try {
      const uniqueIdentifier = process.env.UNIQUE_IDENTIFIER;
      if (uniqueIdentifier) {
        Counter.findOne({ uniqueIdentifier })
          .exec()
          .then(c => { // if current does not exist, initialize it with count == 1;
            if (!c) {
              const now = new Date();
              const count = 1;
              const newCounter = new Counter({
                counter: count,
                createdAt: now,
                lastUpdated: now,
                uniqueIdentifier: uniqueIdentifier,
              });

              // save and return to client
              newCounter
                .save()
                .then(counter => {
                  return res.send(counter);
                })
                .catch(err => {
                  return res.status(500).send({ err });
                });
            } else {

              // if the unique counter exists, update it
              const now = new Date();
              c.counter++;
              c.lastUpdated = now;
              c.save()
                .then(counter => {
                  return res.send(counter);
                })
                .catch(err => {
                  return res.status(500).send({ err });
                });
            }
          });
      } else {
        return res.status(500).send({ err: "UNIQUE_IDENTIFIER is not provided. could not initialize object" });
      }
    } catch (error) {
      return res.status(500).send({ error });
    }
  }
};
