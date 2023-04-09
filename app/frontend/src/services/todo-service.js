import http from "../api-service";

class TodoDataService {
  getAll() {
    return http.get("/todos");
  }

  get(id) {
    return http.get(`/todos/${id}`);
  }

  create(data) {
    return http.post("/todos/add", data);
  }

  update(data) {
    return http.put(`/todos/update/${data.id}`, data);
  }

  delete(id) {
    return http.delete(`/todos/delete/${id}`);
  }

  deleteAll() {
    return http.delete(`/todos`);
  }

  findByTitle(title) {
    return http.get(`/todos?title=${title}`);
  }
}

export default new TodoDataService();