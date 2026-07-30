import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/market/market_bloc.dart';
import '../../../portfolio/presentation/blocs/portfolio/portfolio_bloc.dart';

class TradeTicketScreen extends StatefulWidget {
  final String symbol;

  const TradeTicketScreen({super.key, required this.symbol});

  @override
  State<TradeTicketScreen> createState() => _TradeTicketScreenState();
}

class _TradeTicketScreenState extends State<TradeTicketScreen> {
  bool _isBuy = true;
  final _qtyController = TextEditingController(text: '1');
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_isBuy ? "BUY" : "SELL"} ${widget.symbol}'),
      ),
      body: BlocBuilder<PortfolioBloc, PortfolioState>(
        builder: (context, portfolioState) {
          return BlocBuilder<MarketBloc, MarketState>(
            buildWhen: (prev, curr) =>
                prev.tickers[widget.symbol] != curr.tickers[widget.symbol],
            builder: (context, marketState) {
              final stock = marketState.tickers[widget.symbol]!;
              final parsedQty = int.tryParse(_qtyController.text) ?? 0;
              final projectedOrderVal = parsedQty * stock.ltp;

              final holdingIndex = portfolioState.holdings.indexWhere(
                (h) => h.symbol == widget.symbol,
              );
              final availableToSell = holdingIndex >= 0
                  ? portfolioState.holdings[holdingIndex].quantity
                  : 0;

              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.symbol,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${stock.ltp.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Live Market Price',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isBuy
                                  ? Colors.green
                                  : Colors.grey[300],
                              foregroundColor: _isBuy
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            onPressed: () => setState(() {
                              _isBuy = true;
                              _errorMessage = null;
                            }),
                            child: const Text('BUY'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !_isBuy
                                  ? Colors.red
                                  : Colors.grey[300],
                              foregroundColor: !_isBuy
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            onPressed: () => setState(() {
                              _isBuy = false;
                              _errorMessage = null;
                            }),
                            child: const Text('SELL'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        errorText: _errorMessage,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (_) {
                        setState(() => _errorMessage = null);
                      },
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _isBuy
                                    ? 'Available Cash:'
                                    : 'Available Holdings:',
                              ),
                              Text(
                                _isBuy
                                    ? '₹${portfolioState.balance.toStringAsFixed(2)}'
                                    : '$availableToSell shares',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Estimated Value:',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                '₹${projectedOrderVal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isBuy ? Colors.green : Colors.red,
                        ),
                        onPressed: () {
                          if (parsedQty <= 0) {
                            setState(
                              () => _errorMessage =
                                  'Please enter a valid quantity',
                            );
                            return;
                          }

                          if (_isBuy &&
                              projectedOrderVal > portfolioState.balance) {
                            setState(
                              () => _errorMessage =
                                  'Insufficient Cash! Required: ₹${projectedOrderVal.toStringAsFixed(2)}',
                            );
                            return;
                          }

                          if (!_isBuy && parsedQty > availableToSell) {
                            setState(
                              () => _errorMessage =
                                  'Insufficient Holdings! You have $availableToSell shares',
                            );
                            return;
                          }

                          context.read<PortfolioBloc>().add(
                            ExecuteOrderEvent(
                              symbol: widget.symbol,
                              quantity: parsedQty,
                              ltp: stock.ltp,
                              isBuy: _isBuy,
                            ),
                          );

                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Order Executed!'),
                              content: Text(
                                'Successfully ${_isBuy ? "bought" : "sold"} $parsedQty shares of ${widget.symbol} @ ₹${stock.ltp.toStringAsFixed(2)}',
                              ),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text(
                          _isBuy ? 'SUBMIT BUY ORDER' : 'SUBMIT SELL ORDER',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
