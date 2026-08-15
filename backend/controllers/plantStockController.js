const PlantStock = require('../models/PlantStock');
const { updateStockSummary } = require('../utils/stockHelper');

const getPlantStocks = async (req, res) => {
  try {
    const stocks = await PlantStock.find().sort({ date: -1 });
    res.json(stocks);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const createPlantStock = async (req, res) => {
  try {
    const stock = await PlantStock.create(req.body);
    await updateStockSummary('totalPlantKg', req.body.plantKg);
    res.status(201).json(stock);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const updatePlantStock = async (req, res) => {
  try {
    const oldStock = await PlantStock.findById(req.params.id);
    if (!oldStock) return res.status(404).json({ message: 'Stock not found' });

    const diff = req.body.plantKg - oldStock.plantKg;
    const updatedStock = await PlantStock.findByIdAndUpdate(req.params.id, req.body, { new: true });
    
    if (diff !== 0) {
      await updateStockSummary('totalPlantKg', diff);
    }
    
    res.json(updatedStock);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const deletePlantStock = async (req, res) => {
  try {
    const stock = await PlantStock.findById(req.params.id);
    if (!stock) return res.status(404).json({ message: 'Stock not found' });
    
    await updateStockSummary('totalPlantKg', -stock.plantKg);
    await stock.deleteOne();
    
    res.json({ message: 'Stock removed' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { getPlantStocks, createPlantStock, updatePlantStock, deletePlantStock };
