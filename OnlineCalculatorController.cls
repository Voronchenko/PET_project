public with sharing class OnlineCalculatorController {

    public Decimal operandOne { get; set; }
    public Decimal operandTwo { get; set; }
    public String operationType { get; set; }
    public Decimal result { get; set; }

    public OnlineCalculatorController() {
        this.operandOne = 0;
        this.operandTwo = 0;
        this.operationType = null;
        this.result = 0;
    }

    public PageReference calculate() {

        if (operationType == '+') {
            result = operandOne + operandTwo;
        } else if (operationType == '-') {
            result = operandOne - operandTwo;
        } else if (operationType == '*') {
            result = operandOne * operandTwo;
        } else if (operationType == '/') {
            result = operandOne / operandTwo;
        } else {
            operationType = null;
        }

        return null;
    }

    public PageReference clear() {

        operandOne = 0;
        operandTwo = 0;
        operationType = null;
        result = 0;

        return null;
    }
}