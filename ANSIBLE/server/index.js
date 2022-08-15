const express = require('express')
const bodyParser = require('body-parser')
const cors = require('cors');
const countRouter = require('./routes/counter')


const app = express()

app.use(cors());

app.use(bodyParser.json());

app.use('/api', countRouter);

require('./db');


const port = process.env.PORT || 3001
app.listen(port, () => console.log(`App listening on port ${port}`))