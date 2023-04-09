module.exports = app => {
  const todos  = require("../controllers/todo.controller.js");
  var router   = require("express").Router();

  // Create a new Todo
  router.post("/add", todos.create);

  // Retrieve all Todos
  router.get("/", todos.findAll);

  // Retrieve all done Todos
  router.get("/done", todos.findAllPublished);

  // Retrieve all pending Todos
  router.get("/pending", todos.findAllPublished);

  // Retrieve a single Todo with id
  router.get("/:id", todos.findOne);

  // Update a Todo with id
  router.put("/update/:id", todos.update);

  // Delete a Todo with id
  router.delete("/delete/:id", todos.delete);

  // Delete all Todos
  router.delete("/delete-all", todos.deleteAll);

  app.use('/api/todos', router);
};