import axios from 'axios';

const BASE_URL = "http://localhost:3001/api"



export const incrementCounterAPI = ( cb ) => {
    
    let method = 'post';
    axios({
      method,
      url: `${BASE_URL}/inc`,
      data: null
    })
    .then( res => cb( res.data.counter ) );
  }
