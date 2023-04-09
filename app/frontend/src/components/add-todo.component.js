import React from "react";
import TodoDataService from "../services/todo-service";

const initialState = {
  id: null,
  title: "",
  status: false
};

export default class AddTodo extends React.Component {
  constructor(props) {
    super(props);

    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.state        = initialState;
  }

  handleChange(event) {
    this.setState({title: event.target.value});
  }

  handleSubmit(event) {
    TodoDataService.create(this.state)
      .then(response => {
        this.setState({
          id: response.data.id,
          title: response.data.title,
          status: response.data.status
        });

        this.setState(initialState)
        this.props.onRefresh()

        console.log(response.data);
      })
      .catch(e => {
        console.log(e);
      });

    event.preventDefault();
  }


  render() {
    return (
      <form onSubmit={this.handleSubmit}>        
        <div className="input-group mb-3">
          <input type="text" className="form-control" placeholder="new task..." value={this.state.title} onChange={this.handleChange} required/>
          <button className="btn btn-primary" type="submit">Add Task</button>
        </div>
      </form>
    );
  }
}
