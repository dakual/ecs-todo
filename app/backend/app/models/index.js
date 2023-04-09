const dbConfig  = require("../config/db.config.js");
const Sequelize = require("sequelize");
const sequelize = new Sequelize(dbConfig.DB, dbConfig.USER, dbConfig.PASSWORD, {
  host: dbConfig.HOST,
  dialect: dbConfig.dialect,
  port: dbConfig.port,
});

sequelize.authenticate().then(() => {
  console.log('Connection has been established successfully.');
}).catch((error) => {
  console.error('Unable to connect to the database: ', error);
});

const db = {};
db.Sequelize   = Sequelize;
db.sequelize   = sequelize;
db.todo        = require("./todo.model.js")(sequelize, Sequelize);
module.exports = db;

