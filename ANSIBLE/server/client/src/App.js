import React, {useState, useEffect} from 'react'
import './App.css';
import { incrementCounterAPI } from './API';

function App() {

  const [counter, setCounter] = useState(0)

  console.log(counter)

  useEffect(() => {
    incrementCounterAPI(setCounter)
   }, [])


  return (
    <div className="App">
      {`Hello World ${counter} times! ` }
    </div>
  );
}

export default App;
