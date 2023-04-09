module.exports = (sequelize, Sequelize) => {
  const Todo = sequelize.define("task", {
    title: {
      type: Sequelize.STRING,
      allowNull: false
    },
    status: {
      type: Sequelize.BOOLEAN
    }
  });

  return Todo;
};
