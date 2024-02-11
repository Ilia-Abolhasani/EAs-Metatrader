#include <stderror.mqh>
#include <stdlib.mqh>

#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

// config parameters
double initialDistance = 3;      // Initial distance for the first order
double orderInterval = 0.5;         // Distance between orders in points
int orderCount = 20;            // Number of orders to place on each side
double stopLossDistance = 0.5;     // Stop loss distance in points
double takeProfitDistance = 0.5;   // Take profit distance in points
double Lots = 0.01;             // Lot size for orders
int expirationMinutes = 1000;     // Expiration time for orders in minutes
double stdThreshold = 0.5;     // Standard deviation threshold for placing orders
int stdTicksNumbers = 200;
int removeOrderTime = 180; // seconds
int waitForOrderTime = 180; // seconds
 
datetime lastOrderOpenTime = 0;

// global variables
double tickPrices[];
int tickCounts = 0;


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

void PrintArray(const double &array[])
{
    string arrayString = "";
    int arraySize = ArraySize(array);
    for (int i = 0; i < arraySize; i++)    
        arrayString += DoubleToString(array[i], 5) + " ";
    Print(arrayString);
}

double getAverage(const int _period)
{
    double sum = 0.0;
    for (int i = 0; i < _period; i++)    
        sum += iClose(NULL, 0, i);    
    return sum / _period;
}        

void PlaceOrders()
{
    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);

    // Calculate the distance for the first order
    double firstOrderDistance = initialDistance;

    for (int i = 0; i < orderCount; i++)
    {
        // Calculate expiration time
        datetime expirationTime = iTime(NULL, 0, 0) + expirationMinutes * 60;

        // Place Buy Orders1
        double orderPrice = currentPrice + firstOrderDistance;
        double tp = orderPrice + takeProfitDistance;
        double sl = orderPrice - stopLossDistance;                
        int result = OrderSend(_Symbol, OP_BUYSTOP, Lots, orderPrice , 10, sl, tp, "Buy Order", 0, expirationTime, clrGreen);
        if (result > 0){        
        		Print("Buy order placed. Ticket: ", result);    		
        }
    	  else{    	  
        		int error = GetLastError();
        		string errorDescription = ErrorDescription(error);
    			Print("OrderSend failed with error #", error, ": ", errorDescription);       
		  }   
		  orderPrice = currentPrice - firstOrderDistance;
        tp = orderPrice - takeProfitDistance;
        sl = orderPrice + stopLossDistance;     
        result = OrderSend(_Symbol, OP_SELLSTOP, Lots, orderPrice , 10, sl, tp , "Sell Order", 0, expirationTime, clrRed);
		  if (result > 0){
        		Print("Buy order placed. Ticket: ", result);    		
        }
    	  else{    	  
        		int error = GetLastError();
        		string errorDescription = ErrorDescription(error);
    			Print("OrderSend failed with error #", error, ": ", errorDescription);
		  }        
        // Increment distance for subsequent orders
        firstOrderDistance += orderInterval;
    }
}

double getStdTicks()
{            
    if (tickCounts < stdTicksNumbers )
        return stdThreshold + 1;

    // Calculate mean
    double mean = 0.0;
    for (int i = 0; i < stdTicksNumbers ; i++)    
        mean += tickPrices[i];    
    mean /= stdTicksNumbers ;
			

  	 // Calculate sum of squared differences
	 double ss = 0.0; 
    for (int i = 0; i < stdTicksNumbers ; i++)
    {
        double tickPrice = tickPrices[i];
        ss += MathPow(tickPrice - mean, 2);
    }
    
    return MathSqrt(ss / stdTicksNumbers );
}


void updateTickData()
{    
 	 tickCounts ++;
	 // shift
	 for(int i = stdTicksNumbers - 1; i > 0; i--)
    	tickPrices[i] = tickPrices[i-1];    	                      
    tickPrices[0] = (Bid + Ask) / 2.0;        
}


void CheckAndRemovePendingOrders()
{
    int totalOrders = OrdersTotal();

    for (int i = 0; i < totalOrders; i++)
    {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==false){
         Print("ERROR - Unable to select the order - ", GetLastError());
         continue;
      }     	    	    	
    	// check time
    	int type = OrderType();    	    	
    	if (type != OP_BUYSTOP && type != OP_SELLSTOP)
    		continue;
    	                                 		                 
      // Check if the order hasn't been opened yet            
      if (OrderSymbol() == _Symbol && OrderMagicNumber() ==0)
      {
      	datetime orderOpenTime = OrderOpenTime();
			datetime currentTime = iTime(NULL, 0, 0);
         // Calculate the time difference in seconds
			int timeDifference = currentTime - orderOpenTime;
          // If the order's pending time exceeds 3 minutes (180 seconds), remove the order
			if (timeDifference > removeOrderTime )
			{
				bool deleteResult = OrderDelete(OrderTicket());
				if (deleteResult)
				{
					Print("Pending order removed. Ticket: ", OrderTicket());
				}
				else
				{
					int error = GetLastError();
					string errorDescription = ErrorDescription(error);
               Print("OrderDelete failed with error #", error, ": ", errorDescription);
            }
			}		
		}
    }
}


void OnTick()
{	 
    updateTickData();
    double mean = getAverage(10); // average per minute
    double std = getStdTicks(); // std per ticks     
    CheckAndRemovePendingOrders();
         
    datetime currentTime = iTime(NULL, 0, 0);
    int timeDifferenceSinceLastOrder = currentTime - lastOrderOpenTime;
    
    if (timeDifferenceSinceLastOrder > waitForOrderTime || lastOrderOpenTime == 0) // 120 seconds = 2 minutes
    {
        // Additional condition: if std is below the threshold, place orders
        Print(std);
        if (std < stdThreshold)
        {
            PlaceOrders();
            lastOrderOpenTime = iTime(NULL, 0, 0); // Update the last order open time
        }
    }        
}