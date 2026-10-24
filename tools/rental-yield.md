---
title: Rental Yield Calculator
description: Work out the gross and net rental yield of a flat or shop in India from its price, monthly rent and yearly costs.
permalink: /tools/rental-yield/
---
# Rental yield calculator

Enter the price you pay, the rent you expect and what the property costs you each year. Everything is in ₹.

<form id="ry" class="calc" oninput="ryCalc()">
  <label>Purchase price incl. stamp duty and registration (₹) <input type="number" name="price" min="0" value="5000000"></label>
  <label>Monthly rent (₹) <input type="number" name="rent" min="0" value="15000"></label>
  <label>Yearly costs: maintenance, property tax, repairs (₹) <input type="number" name="costs" min="0" value="24000"></label>
  <label>Months empty per year <input type="number" name="vacant" min="0" max="12" value="1"></label>
  <p aria-live="polite"><strong>Gross yield: <span id="ry-gross"></span></strong><br><strong>Net yield: <span id="ry-net"></span></strong></p>
</form>

<script>
function ryCalc() {
  var f = document.getElementById("ry").elements;
  var price = +f.price.value || 0, rent = +f.rent.value || 0, costs = +f.costs.value || 0;
  var vacant = Math.min(12, Math.max(0, +f.vacant.value || 0));
  var pct = function (x) { return price > 0 ? (x / price * 100).toFixed(2) + "%" : "–"; };
  document.getElementById("ry-gross").textContent = pct(rent * 12);
  document.getElementById("ry-net").textContent = pct(rent * (12 - vacant) - costs);
}
ryCalc();
</script>

## How it is worked out

| Figure | Formula |
|---|---|
| Gross yield | monthly rent × 12 ÷ purchase price × 100 |
| Net yield | (monthly rent × (12 − empty months) − yearly costs) ÷ purchase price × 100 |

**Example with the default numbers:** ₹15,000 × 12 = ₹1,80,000 a year, so the gross yield on ₹50,00,000 is 3.60%. With one empty month and ₹24,000 of costs, you keep ₹1,41,000, a net yield of 2.82%.

## What it leaves out
- Income tax on the rent.
- Home-loan interest, and any rise or fall in the property's price.
- Brokerage and the cost of finding a tenant.

This is a rough check, not investment advice.
