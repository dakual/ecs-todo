import axios from "axios";

export default axios.create({
  baseURL: process.env.REACT_APP_BACKEND_URL || 'http://localhost:3000/api',
  headers: {
    "Content-type": "application/json"
  }
});