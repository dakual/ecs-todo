require("dotenv").config();
const express = require("express");
const cors    = require("cors");
const db      = require("./app/models");
const app     = express();

var corsOptions = {
  origin: process.env.CLIENT_ORIGIN || "http://localhost:8080"
};

// app.use(cors(corsOptions));
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

db.sequelize.sync().then(() => {
  console.log('Todo table created successfully!');
}).catch((error) => {
  console.error('Unable to create table : ', error);
});
// db.sequelize.sync({ force: true }).then(() => {
//   console.log("Drop and re-sync db.");
// });

app.get("/", (req, res) => {
  res.json({ message: "Welcome to application..." });
});

require("./app/routes/todo.routes")(app);

const PORT = process.env.NODE_PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}.`);
});
