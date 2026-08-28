const Production = require('../models/Production');
const { updateStockSummary } = require('../utils/stockHelper');

const getProductions = async (req, res) => {
  try {
    const productions = await Production.find({ admin: req.admin._id }).sort({ productionDate: -1 });
    res.json(productions);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const createProduction = async (req, res) => {
  try {
    const prod = await Production.create({ ...req.body, admin: req.admin._id });
    
    // Business logic: Update stocks
    await updateStockSummary(req.admin._id, 'totalRiceKg', -req.body.riceUsedKg);
    await updateStockSummary(req.admin._id, 'totalPlantKg', -req.body.plantUsedKg);
    await updateStockSummary(req.admin._id, 'totalFlourKg', req.body.flourProducedKg);
    
    res.status(201).json(prod);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const updateProduction = async (req, res) => {
  try {
    const oldProd = await Production.findOne({ _id: req.params.id, admin: req.admin._id });
    if (!oldProd) return res.status(404).json({ message: 'Production not found' });

    const diffRice = req.body.riceUsedKg - oldProd.riceUsedKg;
    const diffPlant = req.body.plantUsedKg - oldProd.plantUsedKg;
    const diffFlour = req.body.flourProducedKg - oldProd.flourProducedKg;

    const updatedProd = await Production.findOneAndUpdate({ _id: req.params.id, admin: req.admin._id }, req.body, { new: true });
    
    if (diffRice !== 0) await updateStockSummary(req.admin._id, 'totalRiceKg', -diffRice);
    if (diffPlant !== 0) await updateStockSummary(req.admin._id, 'totalPlantKg', -diffPlant);
    if (diffFlour !== 0) await updateStockSummary(req.admin._id, 'totalFlourKg', diffFlour);
    
    res.json(updatedProd);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const deleteProduction = async (req, res) => {
  try {
    const prod = await Production.findOne({ _id: req.params.id, admin: req.admin._id });
    if (!prod) return res.status(404).json({ message: 'Production not found' });
    
    // Revert stocks
    await updateStockSummary(req.admin._id, 'totalRiceKg', prod.riceUsedKg);
    await updateStockSummary(req.admin._id, 'totalPlantKg', prod.plantUsedKg);
    await updateStockSummary(req.admin._id, 'totalFlourKg', -prod.flourProducedKg);
    
    await prod.deleteOne();
    
    res.json({ message: 'Production removed' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { getProductions, createProduction, updateProduction, deleteProduction };
