//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


int OnInit()
  {
//string symobl = "XAUUSD";
//int cmd = OP_BUYSTOP ;
//double valume = 0.01;
//double price = Ask + 2;
//int slippage = 10;
//double stoploss = price - 1;
//double takeprofit = price + 1;
//string comment = NULL;
//int magic = 0;
//datetime expiration  =0;
//color  arrow_color = clrGreen ;
//int result = OrderSend(symobl, cmd,valume, price,slippage, stoploss, takeprofit, comment,magic, expiration,arrow_color );
//Alert ("Result :", result );
//if(result == -1){
//      Alert("OrderSend failed with error #",GetLastError());
//}

   if(OrdersTotal() > 0)
     {
      //INITIALIZE TICKET VARIABLES
      int ticket_number, ticket_order_type, ticket_currency_digits, ticket_currency_multiplier;
      string ticket_order_type_name;
      double ticket_profit;

      //LOOK THROUGH ALL OPEN ORDERS
      for(int order_counter = 0; order_counter < OrdersTotal(); order_counter ++)
        {
         //CURRENT OPEN ORDER MATCHES CURRENT SYMBOL
         if(OrderSelect(order_counter, SELECT_BY_POS, MODE_TRADES) == true && OrderSymbol() == Symbol())
           {
            //RETRIEVE OPEN ORDER'S TICKET NUMBER
            ticket_number = OrderTicket();

            //RETRIEVE OPEN ORDER'S TYPE
            ticket_order_type = OrderType();

            //RETRIEVE OPEN ORDER'S CURRENCY DIGITS
            ticket_currency_digits = MarketInfo(OrderSymbol(), MODE_DIGITS);

            //RETRIEVE OPEN ORDER'S CURRENCY MULTIPLIER TO CALCULATE NUMBER OF PIPS
            switch(ticket_currency_digits)
              {
               //CURRENCIES WITH 2 DIGITS
               case 2:
                  ticket_currency_multiplier = 100;
                  break;

               //CURRENCIES WITH 4 DIGITS
               case 4:
                  ticket_currency_multiplier = 10000;
                  break;
              }

            //RETRIEVE OPEN ORDER'S TYPES NAME & PROFIT IN PIPS
            switch(ticket_order_type)
              {
               //BUYING POSITION
               case 0:
                  ticket_order_type_name = "Buying Position";
                  ticket_profit = (OrderClosePrice() - OrderOpenPrice()) * ticket_currency_multiplier;
                  break;

               //SELLING POSITION
               case 1:
                  ticket_order_type_name = "Selling Position";
                  ticket_profit = (OrderOpenPrice() - OrderClosePrice()) * ticket_currency_multiplier;
                  break;
              }

            Alert(OrderSymbol() + " " + ticket_order_type_name + " Ticket: " + ticket_number + ", Open Price: " +
                  OrderOpenPrice() + ", Close Price: " + OrderClosePrice() + ", P/L: " + ticket_profit + " Pips , Stop Loss: " +
                  OrderStopLoss() + ", Take Profit: " + OrderTakeProfit());
           }
        }      
     }
     return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {


  }


void OnTick()
  {
//printf("Bid:" + Bid + "   Ask: " + Ask);
   printf(OrdersTotal());

  }