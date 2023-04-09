import React from "react";
import TodoDataService from "../services/todo-service";


export default class SearchTodo extends React.Component {
  constructor(props) {
    super(props);

    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.state        = { searchTitle: "" };
  }
  
  handleChange(event) {
    this.setState({searchTitle: event.target.value});
  }

  handleSubmit(event) {
    event.preventDefault();

    TodoDataService.findByTitle(this.state.searchTitle)
      .then(response => {
        this.props.onSearch(response.data)
      })
      .catch(e => {
        console.log(e);
      });
  }


  render() {
    return (
      <form className="d-flex" role="search" onSubmit={this.handleSubmit}>        
        <input className="form-control me-2" type="search" placeholder="Search task..." value={this.state.searchTitle} onChange={this.handleChange} required/>
        <button className="btn btn-outline-success" type="submit">Search</button>
      </form>
    );
  }
}
