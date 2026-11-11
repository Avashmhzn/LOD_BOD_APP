import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lodbod_app/core/di/injection_container.dart' as di;
import 'package:lodbod_app/features/shipment/presentation/bloc/bid/bid_bloc.dart';
import 'package:lodbod_app/features/shipment/presentation/bloc/bid/bid_event.dart';
import 'package:lodbod_app/features/shipment/presentation/bloc/bid/bid_state.dart';

class CreateBidPage extends StatefulWidget {
  const CreateBidPage({required this.shipmentId, super.key});

  final String shipmentId;

  @override
  State<CreateBidPage> createState() => _CreateBidPageState();
}

class _CreateBidPageState extends State<CreateBidPage> {
  final _formKey = GlobalKey<FormState>();
  final _fare = TextEditingController();
  final _deliveryDays = TextEditingController(text: '1');

  @override
  void dispose() {
    _fare.dispose();
    _deliveryDays.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext blocContext) async {
    if (!_formKey.currentState!.validate()) return;
    blocContext.read<BidBloc>().add(
      SubmitBid(
        shipmentId: widget.shipmentId,
        fare: double.parse(_fare.text.trim()),
        deliveryDays: int.parse(_deliveryDays.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => di.sl<BidBloc>(),
    child: BlocConsumer<BidBloc, BidState>(
      listener: (context, state) {
        if (state case BidSubmissionFailure(:final message)) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
        } else if (state is BidSubmissionSuccess) {
          context.pop(true);
        }
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: const Text('Place bid'),
          leading: IconButton(
            tooltip: 'Back',
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextFormField(
                  controller: _fare,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Your fare (NPR)',
                    prefixIcon: Icon(Icons.currency_exchange_rounded),
                  ),
                  validator: (value) {
                    final amount = double.tryParse(value?.trim() ?? '');
                    return amount == null || amount <= 0
                        ? 'Enter a fare above zero'
                        : null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _deliveryDays,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Delivery time (days)',
                    prefixIcon: Icon(Icons.schedule_rounded),
                  ),
                  validator: (value) {
                    final days = int.tryParse(value?.trim() ?? '');
                    return days == null || days <= 0
                        ? 'Enter at least one day'
                        : null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: state is BidSubmitting
                      ? null
                      : () => _submit(context),
                  icon: state is BidSubmitting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    state is BidSubmitting ? 'Submitting' : 'Submit bid',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
