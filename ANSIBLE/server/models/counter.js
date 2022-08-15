const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const CounterSchema = new Schema({
    uniqueIdentifier: {
        type:String,
        required: true
    },
    counter:{
        type:Number,
        required:true
    },
    createdAt:{
        type:String,
        required:[true,'This field is required']
    },

    lastUpdated:{
        type:String,
        required:[true,'This field is required']
    }
});


const counter = mongoose.model('counter',CounterSchema);
module.exports=counter;