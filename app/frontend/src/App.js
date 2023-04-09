import './App.css';
import "bootstrap/dist/css/bootstrap.min.css";
import React from "react";
import TodoDataService from "./services/todo-service";
import SearchTodo from "./components/search-todo.component";
import AddTodo from "./components/add-todo.component";


export default class App extends React.Component {
  state = { todos: [] };

  componentDidMount() {
    this.retrieveTodos();
  }

  onSearch = async searchResult => {
    this.setState({ todos: searchResult }, () => {
      console.log(this.state.todos);
    }); 
  };
  
  onRefresh = async event => {
    this.retrieveTodos();
  };

  retrieveTodos() {
    TodoDataService.getAll()
      .then(response => {
        this.setState({
          todos: response.data
        });
        console.log(response.data);
      })
      .catch(e => {
        console.log(e);
      });
  }


  deleteTodo(todo, index) {    
    TodoDataService.delete(todo.id)
      .then(response => {
        this.retrieveTodos();
        console.log(response.data);
      })
      .catch(e => {
        console.log(e);
      });
  }

  updateTodo(todo, status) {
    todo.status = status;
    TodoDataService.update(todo)
      .then(response => {
        this.retrieveTodos();
        console.log(response.data);
      })
      .catch(e => {
        console.log(e);
      });
  }



  render() {
    const { todos } = this.state;
    
    return (
      <div>
        <nav className="navbar navbar-expand-lg navbar-dark bg-dark">
          <div className="container">
            <a className="navbar-brand" href="/">To Do Tasks</a>
            <button className="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
              <span className="navbar-toggler-icon"></span>
            </button>
            <div className="collapse navbar-collapse" id="navbarSupportedContent">
              <ul className="navbar-nav me-auto mb-2 mb-lg-0">
                <li className="nav-item">
                  <a className="nav-link active" aria-current="page" href="/">Home</a>
                </li>
              </ul>
              <SearchTodo onSearch={this.onSearch} />
            </div>
          </div>
        </nav>
        
        <div className="container mt-3">
          <AddTodo onRefresh={this.onRefresh}  />

          <h4>Tasks</h4>
          <ul className="list-group">
            {todos && todos.map((todo, index) => (
              <li className="list-group-item d-flex justify-content-between align-items-center" key={index}>
                {todo.title}
                <div>
                  {todo.status ? (
                    <button type="button" className="btn btn-success me-2" onClick={() => this.updateTodo(todo, false)}>Done</button>
                  ):(
                    <button type="button" className="btn btn-warning me-2" onClick={() => this.updateTodo(todo, true)}>Pending</button>
                  )}
                  <button type="button" className="btn btn-danger" onClick={() => this.deleteTodo(todo, index)}>Delete</button>
                </div>
              </li>
            ))}
          </ul>
        </div>
      </div>
    );
  }
}

