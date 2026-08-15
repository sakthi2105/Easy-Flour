const mongoose = require('mongoose');

const expenseSchema = mongoose.Schema({
  expenseName: { type: String, required: true },
  amount: { type: Number, required: true },
  date: { type: Date, required: true, default: Date.now }
}, { timestamps: true });

module.exports = mongoose.model('Expense', expenseSchema);