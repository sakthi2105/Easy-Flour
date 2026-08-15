const Production = require('../models/Production');
const { updateStockSummary } = require('../utils/stockHelper');

const getProductions = async (req, res) => {
  try {
    const productions = await Production.find().sort({ productionDate: -1 });
    res.json(productions);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const createProduction = async (req, res) => {
  try {
    const prod = await Production.create(req.body);
    
    // Business logic: Update stocks
    await updateStockSummary('totalRiceKg', -req.body.riceUsedKg);
    await updateStockSummary('totalPlantKg', -req.body.plantUsedKg);
    await updateStockSummary('totalFlourKg', req.body.flourProducedKg);
    
    res.status(201).json(prod);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const updateProduction = async (req, res) => {
  try {
    const oldProd = await Production.findById(req.params.id);
    if (!oldProd) return res.status(404).json({ message: 'Production not found' });

    const diffRice = req.body.riceUsedKg - oldProd.riceUsedKg;
    const diffPlant = req.body.plantUsedKg - oldProd.plantUsedKg;
    const diffFlour = req.body.flourProducedKg - oldProd.flourProducedKg;

    const updatedProd = await Production.findByIdAndUpdate(req.params.id, req.body, { new: true });
    
    if (diffRice !== 0) await updateStockSummary('totalRiceKg', -diffRice);
    if (diffPlant !== 0) await updateStockSummary('totalPlantKg', -diffPlant);
    if (diffFlour !== 0) await updateStockSummary('totalFlourKg', diffFlour);
    
    res.json(updatedProd);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const deleteProduction = async (req, res) => {
  try {
    const prod = await Production.findById(req.params.id);
    if (!prod) return res.status(404).json({ message: 'Production not found' });
    
    // Revert stocks
    await updateStockSummary('totalRiceKg', prod.riceUsedKg);
    await updateStockSummary('totalPlantKg', prod.plantUsedKg);
    await updateStockSummary('totalFlourKg', -prod.flourProducedKg);
    
    await prod.deleteOne();
    
    res.json({ message: 'Production removed' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { getProductions, createProduction, updateProduction, deleteProduction };
