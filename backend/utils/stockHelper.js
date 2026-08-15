const StockSummary = require('../models/StockSummary');

// Initialize stock summary if not exists
const initStockSummary = async () => {
  let summary = await StockSummary.findOne();
  if (!summary) {
    summary = await StockSummary.create({});
  }
  return summary;
};

// Update stock summary helper
const updateStockSummary = async (field, amount) => {
  let summary = await initStockSummary();
  summary[field] += amount;
  await summary.save();
};

module.exports = { initStockSummary, updateStockSummary };
