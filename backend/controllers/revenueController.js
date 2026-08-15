const ShopSales = require('../models/ShopSales');
const OtherSales = require('../models/OtherSales');
const Expense = require('../models/Expense');
const StockSummary = require('../models/StockSummary');
const Production = require('../models/Production');
const moment = require('moment');

const getRevenueDashboard = async (req, res) => {
  try {
    const today = moment().startOf('day');
    const thisWeek = moment().startOf('isoWeek');
    const thisMonth = moment().startOf('month');
    const thisYear = moment().startOf('year');

    // Aggregate queries for totals
    const [shopSales, otherSales, expenses, stockSummary] = await Promise.all([
      ShopSales.find(),
      OtherSales.find(),
      Expense.find(),
      StockSummary.findOne()
    ]);

    let totalShopSalesAmount = 0;
    let totalOtherSalesAmount = 0;
    let totalExpenseAmount = 0;
    let totalPendingCollection = 0;

    let todaysRevenue = 0;
    let weeklyRevenue = 0;
    let monthlyRevenue = 0;
    let yearlyRevenue = 0;

    let monthlyExpenseAmount = 0;
    let totalPocketCount = 0;
    let monthlySalesCount = 0;

    let todaysShopSalesAmount = 0;
    let todaysOtherSalesAmount = 0;
    let todaysExpenseAmount = 0;

    shopSales.forEach(sale => {
      totalShopSalesAmount += sale.totalAmount;
      totalPendingCollection += sale.pendingAmount;
      totalPocketCount += sale.pocketCount;

      const saleDate = moment(sale.salesDate);
      if (saleDate.isSameOrAfter(today)) {
        todaysRevenue += sale.totalAmount;
        todaysShopSalesAmount += sale.totalAmount;
      }
      if (saleDate.isSameOrAfter(thisWeek)) weeklyRevenue += sale.totalAmount;
      if (saleDate.isSameOrAfter(thisMonth)) {
        monthlyRevenue += sale.totalAmount;
        monthlySalesCount += 1;
      }
      if (saleDate.isSameOrAfter(thisYear)) yearlyRevenue += sale.totalAmount;
    });

    otherSales.forEach(sale => {
      totalOtherSalesAmount += sale.totalAmount;
      totalPendingCollection += sale.pendingAmount;
      totalPocketCount += sale.pocketCount;

      const saleDate = moment(sale.date);
      if (saleDate.isSameOrAfter(today)) {
        todaysRevenue += sale.totalAmount;
        todaysOtherSalesAmount += sale.totalAmount;
      }
      if (saleDate.isSameOrAfter(thisWeek)) weeklyRevenue += sale.totalAmount;
      if (saleDate.isSameOrAfter(thisMonth)) {
        monthlyRevenue += sale.totalAmount;
        monthlySalesCount += 1;
      }
      if (saleDate.isSameOrAfter(thisYear)) yearlyRevenue += sale.totalAmount;
    });

    expenses.forEach(exp => {
      totalExpenseAmount += exp.amount;

      const expDate = moment(exp.date);
      if (expDate.isSameOrAfter(today)) todaysExpenseAmount += exp.amount;
      if (expDate.isSameOrAfter(thisMonth)) monthlyExpenseAmount += exp.amount;
    });

    // Today's flour production
    const todaysProductions = await Production.find({
      productionDate: { $gte: today.toDate() }
    });
    let todaysFlourProduction = todaysProductions.reduce((acc, curr) => acc + curr.flourProducedKg, 0);

    const totalSalesAmount = totalShopSalesAmount + totalOtherSalesAmount;
    const netProfit = totalSalesAmount - totalExpenseAmount;

    res.json({
      stock: stockSummary || { totalRiceKg: 0, totalPlantKg: 0, totalFlourKg: 0 },
      todaysFlourProduction,
      todaysShopSales: todaysShopSalesAmount,
      todaysOtherSales: todaysOtherSalesAmount,
      todaysExpenses: todaysExpenseAmount,
      todaysRevenue,
      weeklyRevenue,
      monthlyRevenue,
      yearlyRevenue,
      netProfit,
      totalSales: totalSalesAmount,
      totalExpense: totalExpenseAmount,
      pendingCollection: totalPendingCollection,
      
      // New metrics requested
      totalPocketCount,
      monthlyExpenseAmount,
      monthlyProfit: monthlyRevenue - monthlyExpenseAmount,
      monthlySalesCount
    });

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { getRevenueDashboard };
