#include <stderror.mqh>
#include <stdlib.mqh>

#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

// config parameters
double stopLoss = 2.5;   
double takeProfit = 3;   
double Lots = 0.01;     
int waitForOrderTime = 60; // seconds

// global variables
double tickPrices[];
int tickCounts = 0;
datetime lastOrderOpenTime = 0;


int OnInit()
{  	 	 	 
	 // create zero array for tickPrices
    ArraySetAsSeries(tickPrices, true);
    ArrayResize(tickPrices, stdTicksNumbers);
    ArraySetAsSeries(tickPrices, false); 
    ArrayInitialize(tickPrices, 0.0);
    
    return(INIT_SUCCEEDED);
}
	
void OnDeinit(const int reason)
{	
}


void PlaceOrderBuy()
{
	 double orderPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);                        
    double tp = orderPrice + takeProfitDistance;
    double sl = orderPrice - stopLossDistance;                
    int result = OrderSend(_Symbol, OP_BUY, Lots, orderPrice , 10, sl, tp, "Buy Order", 0, 0, clrGreen);
    if (result > 0){        
    	Print("Buy order placed. Ticket: ", result);    		
    }
    else{    	  
    	int error = GetLastError();
      string errorDescription = ErrorDescription(error);
    	Print("OrderSend failed with error #", error, ": ", errorDescription);       
    }   		  
}

void PlaceOrderSell()
{
    double orderPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);                        
    double tp = orderPrice - takeProfitDistance;
    double sl = orderPrice + stopLossDistance;                
    int result = OrderSend(_Symbol, OP_SELL, Lots, orderPrice , 10, sl, tp, "Sell Order", 0, 0, clrRed);
    if (result > 0){        
    	Print("Sell order placed. Ticket: ", result);    		
    }
    else{    	  
    	int error = GetLastError();
      string errorDescription = ErrorDescription(error);
    	Print("OrderSend failed with error #", error, ": ", errorDescription);       
    }   		  
}

void updateTickData()
{    
 	 tickCounts ++;
	 // shift
	 for(int i = stdTicksNumbers - 1; i > 0; i--)
    	tickPrices[i] = tickPrices[i-1];    	                      
    tickPrices[0] = (Bid + Ask) / 2.0;        
}

double getSlope(const double &array[]){
	return 0;
}
bool BuyIsOK(){

}

bool SellIsOK(){
}

void OnTick()
{	 
    updateTickData();                 
    datetime currentTime = iTime(NULL, 0, 0);
    int timeDifferenceSinceLastOrder = currentTime - lastOrderOpenTime;    
    if (timeDifferenceSinceLastOrder > waitForOrderTime || lastOrderOpenTime == 0) 
    {       		             
        if (BuyIsOK())
        {
            PlaceOrderBuy();            
            lastOrderOpenTime = iTime(NULL, 0, 0); 
        }
        else if (SellIsOK())
        {
            PlaceOrderSell();
            lastOrderOpenTime = iTime(NULL, 0, 0); 
        }
    }        
}