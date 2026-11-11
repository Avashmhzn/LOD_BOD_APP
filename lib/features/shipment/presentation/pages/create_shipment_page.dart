import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/shipment_entity.dart';
import '../../domain/entities/shipment_status_event.dart';
import '../bloc/create_shipment/create_shipment_bloc.dart';
import '../bloc/create_shipment/create_shipment_event.dart';
import '../bloc/create_shipment/create_shipment_state.dart';

class CreateShipmentPage extends StatefulWidget {
  const CreateShipmentPage({super.key});

  @override
  State<CreateShipmentPage> createState() => _CreateShipmentPageState();
}

class _CreateShipmentPageState extends State<CreateShipmentPage> {
  static const _orange = Color(0xFFE84012);
  Color get _ink => Theme.of(context).colorScheme.onSurface;
  Color get _muted => Theme.of(context).colorScheme.onSurfaceVariant;
  Color get _line => Theme.of(context).colorScheme.outlineVariant;
  Color get _background => Theme.of(context).scaffoldBackgroundColor;
  static const _steps = ['Route', 'Cargo', 'Trucks', 'Review'];
  static const _materials = [
    'Cement',
    'Steel',
    'Electronics',
    'Gravel & Sand',
    'FMCG',
    'Furniture',
    'Rice sacks',
    'Other',
  ];
  static const _natureOptions = [
    'Stackable',
    'Hazardous',
    'Fragile',
    'Perishable',
    'Liquid',
    'Oversized',
  ];
  static const _defaultPickupContacts = [
    'Ram Shrestha · 9841000001',
    'Sita Thapa',
    'Gopi KC',
  ];
  static const _defaultConsignees = [
    'Ramesh Yadav · 9857000002',
    'Suresh Shah',
    'Hari Pradhan',
  ];
  static const _truckTypes = [
    ('Open', Icons.local_shipping_outlined),
    ('Closed', Icons.rv_hookup_outlined),
    ('Trailer', Icons.local_shipping_rounded),
    ('Container', Icons.directions_bus_filled_outlined),
    ('Tipper', Icons.fire_truck_outlined),
    ('Tanker', Icons.local_gas_station_outlined),
  ];
  static const _weightClasses = ['10 W', '12 W', '14 W'];
  static const _timeWindows = ['Morning', 'Afternoon', 'Evening', 'Full day'];

  final _formKey = GlobalKey<FormState>();
  final _pickup = TextEditingController();
  final _destination = TextEditingController();
  final _cargo = TextEditingController();
  final _weight = TextEditingController();
  final _capacity = TextEditingController();
  final _consignmentValue = TextEditingController();
  final _fare = TextEditingController();
  final _notes = TextEditingController();
  final _stops = <Map<String, dynamic>>[];
  final _nature = <String>{'Stackable'};
  final _pickupContacts = [..._defaultPickupContacts];
  final _consignees = [..._defaultConsignees];

  int _step = 0;
  int _truckCount = 1;
  String _orderType = 'Normal';
  String _material = 'Cement';
  String _pickupContact = _defaultPickupContacts.first;
  String _consignee = _defaultConsignees.first;
  String _truckType = 'Open';
  String _weightClass = '12 W';
  String _capacityRule = 'Or above';
  String _billing = 'VAT bill';
  String _pickupWindow = 'Evening';
  String _deliveryWindow = 'Afternoon';
  DateTime _pickupDate = DateTime.now().add(const Duration(days: 1));
  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 3));
  bool _saving = false;
  String? _completedReference;
  String? _submissionId;

  DateTime get _pickupAt => _atWindow(_pickupDate, _pickupWindow);
  DateTime get _deliveryAt => _atWindow(_deliveryDate, _deliveryWindow);

  @override
  void dispose() {
    _pickup.dispose();
    _destination.dispose();
    _cargo.dispose();
    _weight.dispose();
    _capacity.dispose();
    _consignmentValue.dispose();
    _fare.dispose();
    _notes.dispose();
    super.dispose();
  }

  DateTime _atWindow(DateTime date, String window) {
    final hour = switch (window) {
      'Morning' => 9,
      'Afternoon' => 14,
      'Evening' => 17,
      _ => 12,
    };
    return DateTime(date.year, date.month, date.day, hour);
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  bool _validateStep() {
    if (_step == 0) {
      if (_pickup.text.trim().isEmpty || _destination.text.trim().isEmpty) {
        _message('Enter both pickup and delivery locations.');
        return false;
      }
      if (_pickup.text.trim().toLowerCase() ==
          _destination.text.trim().toLowerCase()) {
        _message('Pickup and delivery locations must be different.');
        return false;
      }
      if (_pickupAt.isBefore(DateTime.now())) {
        _message('Choose a pickup time in the future.');
        return false;
      }
      if (_deliveryAt.isBefore(_pickupAt)) {
        _message('Delivery time must be after pickup.');
        return false;
      }
      return true;
    }
    if (_step == 1) {
      if (_nature.isEmpty || _pickupContact.isEmpty || _consignee.isEmpty) {
        _message('Choose cargo nature and both contacts.');
        return false;
      }
      return true;
    }
    if (_step == 2) {
      final capacity = double.tryParse(_capacity.text.trim());
      final loadWeight = double.tryParse(_weight.text.trim());
      if (capacity == null || capacity <= 0) {
        _message('Enter a valid truck capacity.');
        return false;
      }
      if (loadWeight == null || loadWeight <= 0) {
        _message('Enter a valid load weight.');
        return false;
      }
      if (loadWeight > capacity) {
        _message('Load weight cannot exceed truck capacity.');
        return false;
      }
      return true;
    }
    return true;
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _continue() {
    if (!_validateStep()) return;
    setState(() => _step = (_step + 1).clamp(0, _steps.length - 1));
  }

  void _goToStep(int index) {
    if (index <= _step) setState(() => _step = index);
  }

  Future<void> _chooseDate({required bool pickup}) async {
    final current = pickup ? _pickupDate : _deliveryDate;
    final today = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(today.year + 2),
    );
    if (date == null || !mounted) return;
    setState(() {
      if (pickup) {
        _pickupDate = date;
      } else {
        _deliveryDate = date;
      }
    });
  }

  Future<void> _addContact({required bool pickup}) async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ContactEditorSheet(
        title: pickup ? 'New pickup contact' : 'New consignee',
      ),
    );
    if (result == null || !mounted) return;
    final name = result['name']?.trim() ?? '';
    final phone = result['phone']?.trim() ?? '';
    if (name.isEmpty) return;
    final contact = phone.isEmpty ? name : '$name · $phone';
    setState(() {
      if (pickup) {
        if (!_pickupContacts.contains(contact)) _pickupContacts.add(contact);
        _pickupContact = contact;
      } else {
        if (!_consignees.contains(contact)) _consignees.add(contact);
        _consignee = contact;
      }
    });
  }

  Future<void> _addStop() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _StopEditorSheet(
        stopNumber: _stops.length + 1,
        initialPickup: _pickup.text.trim(),
        initialDestination: _destination.text.trim(),
      ),
    );
    if (result != null && mounted) setState(() => _stops.add(result));
  }

  Future<void> _saveDraft(BuildContext blocContext) async =>
      _submit(blocContext, draft: true);

  Future<void> _placeOrder(BuildContext blocContext) async =>
      _submit(blocContext, draft: false);

  Future<void> _submit(BuildContext blocContext, {required bool draft}) async {
    if (!draft) {
      for (var index = 0; index < 3; index++) {
        final currentStep = _step;
        _step = index;
        final valid = _validateStep();
        _step = currentStep;
        if (!valid) {
          setState(() => _step = index);
          return;
        }
      }
      if (_pickupAt.isBefore(DateTime.now())) {
        setState(() => _step = 0);
        _message('Choose a pickup time in the future.');
        return;
      }
    }

    final user = di.sl<FirebaseAuth>().currentUser;
    if (user == null) {
      _message('Sign in before creating a shipment.');
      return;
    }

    setState(() => _saving = true);

    final now = DateTime.now().toUtc();
    final loadWeight = double.tryParse(_weight.text.trim());
    final capacity = double.tryParse(_capacity.text.trim());
    final fare = double.tryParse(_fare.text.trim());
    final consignmentValue = double.tryParse(_consignmentValue.text.trim());
    final description = _cargo.text.trim().isEmpty
        ? _material
        : '$_material · ${_cargo.text.trim()}';

    final shipment = ShipmentEntity(
      id: _submissionId ??= di
          .sl<FirebaseFirestore>()
          .collection('shipments')
          .doc()
          .id,
      reference: null,
      pickupLocation: _pickup.text.trim().isEmpty ? null : _pickup.text.trim(),
      deliveryLocation: _destination.text.trim().isEmpty
          ? null
          : _destination.text.trim(),
      cargoDescription: description,
      cargoCategory: _material,
      weight: loadWeight,
      weightUnit: 'tonne',
      weightKg: loadWeight == null ? null : loadWeight * 1000,
      vehicleType: '$_weightClass $_truckType',
      pickupAt: draft && _pickup.text.trim().isEmpty ? null : _pickupAt.toUtc(),
      expectedFare: fare,
      contactNumber: _pickupContact.contains('·')
          ? _pickupContact.split('·').last.trim()
          : null,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      createdBy: user.uid,
      status: draft ? 'draft' : 'awaiting_bids',
      bidCount: 0,
      createdAt: now,
      statusHistory: [
        ShipmentStatusEvent(status: draft ? 'draft' : 'awaiting_bids', at: now),
      ],
      extraData: {
        'orderType': _orderType.toLowerCase(),
        'natureOfConsignment': _nature.toList(),
        'pickupContact': _pickupContact,
        'consignee': _consignee,
        'deliveryAt': _deliveryAt.toUtc(),
        'pickupWindow': _pickupWindow,
        'deliveryWindow': _deliveryWindow,
        'truckCount': _truckCount,
        'truckType': _truckType,
        'weightClass': _weightClass,
        'capacityRule': _capacityRule,
        'capacityTonnes': capacity,
        'billingType': _billing,
        'consignmentValueNpr': consignmentValue,
        'intermediateStops': List<Map<String, dynamic>>.from(_stops),
      },
    );
    blocContext.read<CreateShipmentBloc>().add(
      SubmitShipment(shipment: shipment, isDraft: draft),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = di.sl<FirebaseAuth>().currentUser;
    final postingName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!
        : (user?.email ?? 'Your account');

    return BlocProvider(
      create: (_) => di.sl<CreateShipmentBloc>(),
      child: BlocListener<CreateShipmentBloc, CreateShipmentState>(
        listener: (context, state) {
          if (state is CreatingShipment) {
            setState(() => _saving = true);
          } else if (state is CreateShipmentFailure) {
            setState(() => _saving = false);
            _message(state.message);
          } else if (state is CreateShipmentSuccess) {
            setState(() => _saving = false);
            if (state.isDraft) {
              _message('Draft saved.');
              context.pop(true);
            } else {
              setState(() => _completedReference = state.shipment.reference!);
            }
          }
        },
        child: BlocBuilder<CreateShipmentBloc, CreateShipmentState>(
          builder: (context, state) => Scaffold(
            backgroundColor: _background,
            body: SafeArea(
              child: _completedReference != null
                  ? _successView()
                  : Column(
                      children: [
                        _topBar(postingName, context),
                        _stepBar(),
                        _orderTypeControl(),
                        if (_step > 0) _routeSummary(),
                        Expanded(
                          child: Form(
                            key: _formKey,
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(13, 8, 13, 18),
                              children: [
                                switch (_step) {
                                  0 => _routeStep(),
                                  1 => _cargoStep(),
                                  2 => _trucksStep(),
                                  _ => _reviewStep(),
                                },
                              ],
                            ),
                          ),
                        ),
                        _bottomAction(context),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _successView() => Column(
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: _iconButton(
            Icons.close_rounded,
            'Close',
            () => context.pop(true),
          ),
        ),
      ),
      Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: _orange,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: _orange.withValues(alpha: 0.18),
                        blurRadius: 28,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Order placed',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Your request is live. We will notify you when the first bid arrives.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _muted, fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 22),
                _panel(
                  child: Column(
                    children: [
                      Text(
                        'REQUEST CREATED',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Divider(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _completedReference ?? '',
                              style: TextStyle(
                                color: _ink,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            '$_truckCount ${_truckCount == 1 ? 'truck' : 'trucks'}',
                            style: TextStyle(color: _muted, fontSize: 10),
                          ),
                          const SizedBox(width: 8),
                          _smallTag('Awaiting bids'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(13, 8, 13, 10),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 49,
              child: FilledButton(
                onPressed: () => context.pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: _orange,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'View requests & bids',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            TextButton(
              onPressed: _resetForm,
              child: Text(
                'Post another load',
                style: TextStyle(color: _orange, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  void _resetForm() {
    _pickup.clear();
    _destination.clear();
    _cargo.clear();
    _weight.clear();
    _capacity.clear();
    _consignmentValue.clear();
    _fare.clear();
    _notes.clear();
    setState(() {
      _completedReference = null;
      _step = 0;
      _truckCount = 1;
      _orderType = 'Normal';
      _material = 'Cement';
      _pickupContacts
        ..clear()
        ..addAll(_defaultPickupContacts);
      _consignees
        ..clear()
        ..addAll(_defaultConsignees);
      _pickupContact = _defaultPickupContacts.first;
      _consignee = _defaultConsignees.first;
      _truckType = 'Open';
      _weightClass = '12 W';
      _capacityRule = 'Or above';
      _billing = 'VAT bill';
      _nature
        ..clear()
        ..add('Stackable');
      _stops.clear();
    });
  }

  Widget _topBar(String postingName, BuildContext blocContext) => Padding(
    padding: const EdgeInsets.fromLTRB(13, 4, 13, 7),
    child: Row(
      children: [
        _iconButton(Icons.close_rounded, 'Close', () => context.pop(false)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Post a load',
                style: TextStyle(
                  color: _ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Posting as $postingName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: _muted, fontSize: 10.5),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        OutlinedButton.icon(
          onPressed: _saving ? null : () => _saveDraft(blocContext),
          icon: Icon(Icons.save_outlined, size: 14),
          label: Text('Save draft'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _ink,
            textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            side: BorderSide(color: _line),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            minimumSize: const Size(0, 36),
          ),
        ),
      ],
    ),
  );

  Widget _stepBar() => Padding(
    padding: const EdgeInsets.fromLTRB(13, 0, 13, 10),
    child: Row(
      children: List.generate(_steps.length, (index) {
        final selected = index == _step;
        final completed = index < _step;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == _steps.length - 1 ? 0 : 6),
            child: InkWell(
              onTap: completed ? () => _goToStep(index) : null,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? _orange
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? _orange
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (completed) ...[
                      Icon(Icons.check_rounded, size: 12, color: _orange),
                      const SizedBox(width: 3),
                    ],
                    Text(
                      '${index + 1} ${_steps[index]}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? Colors.white : _muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    ),
  );

  Widget _orderTypeControl() => Padding(
    padding: const EdgeInsets.fromLTRB(13, 0, 13, 9),
    child: Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _segmentedType('Normal', Icons.bolt_rounded),
          _segmentedType('Contract', Icons.description_outlined),
        ],
      ),
    ),
  );

  Widget _segmentedType(String label, IconData icon) {
    final selected = _orderType == label;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _orderType = label),
        borderRadius: BorderRadius.circular(11),
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: selected ? _orange : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: selected ? Colors.white : _muted),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : _muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _routeSummary() => Padding(
    padding: const EdgeInsets.fromLTRB(13, 0, 13, 3),
    child: Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => _goToStep(0),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: _line),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: _orange, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_pickup.text.isEmpty ? 'Pickup' : _pickup.text} → ${_destination.text.isEmpty ? 'Delivery' : _destination.text} · ${DateFormat('EEE').format(_pickupDate)} ${_pickupWindow.toLowerCase()} · $_material',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _ink,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.edit_outlined, size: 15, color: _orange),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _routeStep() => _panel(
    highlighted: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(1, 'Route & schedule'),
        const SizedBox(height: 12),
        _locationField('Pickup location', _pickup, Icons.trip_origin_rounded),
        const SizedBox(height: 9),
        _locationField('Delivery location', _destination, Icons.location_on),
        const SizedBox(height: 6),
        _recentPlaces(),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addStop,
            icon: Icon(Icons.alt_route_rounded, size: 15),
            label: Text('Add pickup point or en-route stop'),
            style: TextButton.styleFrom(
              foregroundColor: _orange,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        if (_stops.isNotEmpty) ...[
          for (var i = 0; i < _stops.length; i++) _stopTile(i, removable: true),
        ],
        _label('Pickup date *'),
        _dateChoices(pickup: true),
        const SizedBox(height: 10),
        _label('Pickup time *'),
        _timeChoices(pickup: true),
        const SizedBox(height: 12),
        _label('Delivery date *'),
        _dateChoices(pickup: false),
        const SizedBox(height: 10),
        _label('Delivery time *'),
        _timeChoices(pickup: false),
      ],
    ),
  );

  Widget _cargoStep() => _panel(
    highlighted: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(2, 'Cargo & contacts'),
        const SizedBox(height: 13),
        _label('Material *'),
        _chipWrap(
          _materials,
          selected: {_material},
          onSelected: (value) => setState(() => _material = value),
        ),
        const SizedBox(height: 11),
        _textField(
          label: 'Cargo description',
          hint: 'Optional details about the goods',
          controller: _cargo,
          icon: Icons.inventory_2_outlined,
          requiredField: false,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _label('Nature of consignment *')),
            Text(
              'Select one or more',
              style: TextStyle(color: _muted, fontSize: 9),
            ),
          ],
        ),
        _chipWrap(
          _natureOptions,
          selected: _nature,
          onSelected: (value) => setState(() {
            if (!_nature.add(value)) _nature.remove(value);
          }),
        ),
        const SizedBox(height: 13),
        _label('Pickup contact *'),
        _chipWrap(
          [..._pickupContacts, '＋ New'],
          selected: {_pickupContact},
          onSelected: (value) {
            if (value == '＋ New') {
              _addContact(pickup: true);
            } else {
              setState(() => _pickupContact = value);
            }
          },
        ),
        const SizedBox(height: 13),
        _label('Consignee at delivery *'),
        _chipWrap(
          [..._consignees, '＋ New'],
          selected: {_consignee},
          onSelected: (value) {
            if (value == '＋ New') {
              _addContact(pickup: false);
            } else {
              setState(() => _consignee = value);
            }
          },
        ),
        const SizedBox(height: 12),
        _textField(
          label: 'Instructions (optional)',
          hint: 'Handling or delivery notes',
          controller: _notes,
          icon: Icons.notes_rounded,
          requiredField: false,
          maxLines: 2,
        ),
      ],
    ),
  );

  Widget _trucksStep() => _panel(
    highlighted: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _sectionTitle(3, 'Trucks')),
            Text(
              '$_truckCount ${_truckCount == 1 ? 'truck' : 'trucks'}',
              style: TextStyle(color: _muted, fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _truckCountControl(),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Text(
                'Truck 1',
                style: TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
            _smallTag(_billing.contains('VAT') ? 'VAT' : 'Non-VAT'),
          ],
        ),
        const SizedBox(height: 12),
        _label('Vehicle type *'),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _truckTypes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 0.88,
          ),
          itemBuilder: (context, index) {
            final item = _truckTypes[index];
            final selected = _truckType == item.$1;
            return InkWell(
              onTap: () => setState(() => _truckType = item.$1),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFFFEFEB)
                      : const Color(0xFFF2F2F4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: selected ? _orange : _line),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.$2, color: selected ? _orange : _muted, size: 19),
                    const SizedBox(height: 4),
                    Text(
                      item.$1,
                      maxLines: 1,
                      style: TextStyle(
                        color: selected ? _orange : _muted,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _chipWrap(
          _weightClasses,
          selected: {_weightClass},
          onSelected: (value) => setState(() => _weightClass = value),
          compact: true,
        ),
        const SizedBox(height: 7),
        _chipWrap(
          const ['Exact', 'Or above'],
          selected: {_capacityRule},
          onSelected: (value) => setState(() => _capacityRule = value),
          compact: true,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _textField(
                label: 'Capacity (t) *',
                hint: 'e.g. 18',
                controller: _capacity,
                icon: Icons.scale_outlined,
                numeric: true,
                requiredField: false,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _textField(
                label: 'Load weight (t) *',
                hint: 'e.g. 12',
                controller: _weight,
                icon: Icons.inventory_2_outlined,
                numeric: true,
                requiredField: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _label('Billing *')),
            Expanded(child: _label('No. of trucks')),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _chipWrap(
                const ['VAT bill', 'Non-VAT'],
                selected: {_billing},
                onSelected: (value) => setState(() => _billing = value),
                compact: true,
              ),
            ),
            const SizedBox(width: 8),
            _stepper(),
          ],
        ),
        const SizedBox(height: 12),
        _textField(
          label: 'Consignment value per truck (NPR) *',
          hint: 'e.g. 750000',
          controller: _consignmentValue,
          icon: Icons.currency_rupee_rounded,
          numeric: true,
          requiredField: false,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _label('Stops on the way')),
            TextButton.icon(
              onPressed: _addStop,
              icon: Icon(Icons.add_rounded, size: 15),
              label: Text('Add stop'),
              style: TextButton.styleFrom(
                foregroundColor: _orange,
                textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        if (_stops.isEmpty)
          Text(
            'Optional pickup or drop points can be added here.',
            style: TextStyle(color: _muted, fontSize: 10),
          )
        else
          for (var i = 0; i < _stops.length; i++) _stopTile(i, removable: true),
      ],
    ),
  );

  Widget _reviewStep() {
    final cargo = _cargo.text.trim().isEmpty
        ? _material
        : '$_material · ${_cargo.text.trim()}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _panel(
          highlighted: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Review your order',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _goToStep(0),
                    child: Text('Edit'),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              _reviewRow(
                'Route',
                '${_pickup.text} → ${_stops.map((stop) => stop['location']).join(' → ')}${_stops.isEmpty ? '' : ' → '}${_destination.text}',
              ),
              _reviewRow(
                'Pickup',
                '${DateFormat('EEE, d MMM').format(_pickupAt)} · $_pickupWindow · $_pickupContact',
              ),
              _reviewRow(
                'Delivery',
                '${DateFormat('d MMM').format(_deliveryAt)} · $_deliveryWindow · $_consignee',
              ),
              _reviewRow('Cargo', '$cargo · ${_nature.join(', ')}'),
              _reviewRow(
                'Trucks',
                '$_truckCount · $_weightClass $_truckType · ${_weight.text} t',
              ),
              _reviewRow(
                'Billing',
                '$_billing · $_capacityRule ${_capacity.text} t',
              ),
              if (_consignmentValue.text.isNotEmpty)
                _reviewRow(
                  'Consignment value',
                  '${formatNpr(double.tryParse(_consignmentValue.text) ?? 0)} per truck',
                ),
              if (_fare.text.isNotEmpty)
                _reviewRow(
                  'Expected fare',
                  formatNpr(double.tryParse(_fare.text) ?? 0),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0EC),
            border: Border.all(color: const Color(0xFFF7C6B9)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 17, color: _orange),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Placing the order makes it available to carriers for bidding. Your shipment details will be saved to your Firebase account.',
                  style: TextStyle(
                    color: Color(0xFF9B513D),
                    fontSize: 10,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bottomAction(BuildContext blocContext) {
    final actionLabel = switch (_step) {
      0 => 'Continue to cargo',
      1 => 'Continue to trucks',
      2 => 'Continue to review',
      _ => 'Place order',
    };
    final footerLabel = switch (_step) {
      0 => 'Fill route to continue',
      1 => 'Cargo and contact details',
      2 =>
        '$_truckCount ${_truckCount == 1 ? 'truck' : 'trucks'} · ${_stops.length} extra stops',
      _ => 'Review details before posting',
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 8, 13, 9),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: _line)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Step ${_step + 1} of 4',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    TextSpan(
                      text: ' · $footerLabel',
                      style: TextStyle(color: _muted),
                    ),
                  ],
                ),
                style: TextStyle(color: _ink, fontSize: 9.5),
              ),
            ),
            const SizedBox(height: 7),
            SizedBox(
              width: double.infinity,
              height: 49,
              child: FilledButton.icon(
                onPressed: _saving
                    ? null
                    : _step == 3
                    ? () => _placeOrder(blocContext)
                    : _continue,
                iconAlignment: IconAlignment.end,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        _step == 3
                            ? Icons.near_me_rounded
                            : Icons.arrow_forward_rounded,
                        size: 18,
                      ),
                label: Text(
                  _saving ? 'Saving...' : actionLabel,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _locationField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(label),
      TextFormField(
        controller: controller,
        textCapitalization: TextCapitalization.words,
        style: TextStyle(color: _ink, fontSize: 12),
        decoration: _decoration('Search city or area', icon),
      ),
    ],
  );

  Widget _recentPlaces() => Padding(
    padding: const EdgeInsets.only(top: 7),
    child: Row(
      children: [
        Text(
          'RECENT',
          style: TextStyle(
            color: _muted,
            fontSize: 8,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 6),
        for (final city in const ['Kalimati', 'Bhaktapur', 'Hetauda'])
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: _smallChoice(
              city,
              false,
              () => setState(() => _destination.text = city),
            ),
          ),
      ],
    ),
  );

  Widget _dateChoices({required bool pickup}) {
    final selected = pickup ? _pickupDate : _deliveryDate;
    final now = DateTime.now();
    final options = <(String, DateTime)>[
      ('Today', DateTime(now.year, now.month, now.day)),
      ('Tomorrow', DateTime(now.year, now.month, now.day + 1)),
      ('+2 days', DateTime(now.year, now.month, now.day + 2)),
    ];
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final option in options)
          _smallChoice(
            option.$1,
            _sameDay(selected, option.$2),
            () => setState(() {
              if (pickup) {
                _pickupDate = option.$2;
              } else {
                _deliveryDate = option.$2;
              }
            }),
          ),
        _smallChoice(
          'Pick date',
          !options.any((option) => _sameDay(selected, option.$2)),
          () => _chooseDate(pickup: pickup),
          icon: Icons.calendar_month_outlined,
        ),
      ],
    );
  }

  Widget _timeChoices({required bool pickup}) => Wrap(
    spacing: 6,
    runSpacing: 6,
    children: [
      for (final window in _timeWindows)
        _smallChoice(
          window,
          (pickup ? _pickupWindow : _deliveryWindow) == window,
          () => setState(() {
            if (pickup) {
              _pickupWindow = window;
            } else {
              _deliveryWindow = window;
            }
          }),
          subtitle: switch (window) {
            'Morning' => '06–12',
            'Afternoon' => '12–18',
            'Evening' => '15–20',
            _ => '06–20',
          },
        ),
    ],
  );

  Widget _truckCountControl() => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _squareAction(Icons.remove_rounded, 'Remove truck', () {
        if (_truckCount > 1) setState(() => _truckCount--);
      }),
      SizedBox(
        width: 35,
        child: Text(
          '$_truckCount',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _ink,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      _squareAction(Icons.add_rounded, 'Add truck', () {
        if (_truckCount < 3) setState(() => _truckCount++);
      }),
    ],
  );

  Widget _stepper() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xFFF2F2F4),
      borderRadius: BorderRadius.circular(12),
    ),
    child: _truckCountControl(),
  );

  Widget _squareAction(IconData icon, String tooltip, VoidCallback onPressed) =>
      SizedBox(
        width: 29,
        height: 29,
        child: IconButton(
          onPressed: onPressed,
          tooltip: tooltip,
          padding: EdgeInsets.zero,
          icon: Icon(icon, size: 16, color: _orange),
        ),
      );

  Widget _stopTile(int index, {required bool removable}) {
    final stop = _stops[index];
    final isPickup = stop['type'] == 'pickup';
    final weightTonnes = (stop['weightTonnes'] as num?)?.toDouble() ?? 0;
    final contact = (stop['consignee'] ?? '').toString();
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: _orange,
            child: Text(
              '${index + 1}',
              style: TextStyle(color: Colors.white, fontSize: 9),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isPickup ? 'Pickup point' : 'Drop'} ${index + 1}',
                  style: TextStyle(
                    color: _orange,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${stop['location']}',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (contact.isNotEmpty)
                  Text(contact, style: TextStyle(color: _muted, fontSize: 9)),
              ],
            ),
          ),
          if (!isPickup && weightTonnes > 0)
            Text(
              '$weightTonnes t',
              style: TextStyle(
                color: _ink,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          if (removable)
            IconButton(
              onPressed: () => setState(() => _stops.removeAt(index)),
              tooltip: 'Remove stop',
              visualDensity: VisualDensity.compact,
              icon: Icon(
                Icons.delete_outline_rounded,
                color: _orange,
                size: 17,
              ),
            ),
        ],
      ),
    );
  }

  Widget _panel({required Widget child, bool highlighted = false}) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: highlighted ? const Color(0xFFF4B7A8) : const Color(0xFFE8E8EC),
        width: highlighted ? 1.2 : 1,
      ),
    ),
    child: child,
  );

  Widget _sectionTitle(int number, String title) => Row(
    children: [
      CircleAvatar(
        radius: 11,
        backgroundColor: _orange,
        child: Text(
          '$number',
          style: TextStyle(
            color: Theme.of(context).colorScheme.surface,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      const SizedBox(width: 9),
      Text(
        title,
        style: TextStyle(
          color: _ink,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: TextStyle(color: _ink, fontSize: 10, fontWeight: FontWeight.w700),
    ),
  );

  Widget _textField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool numeric = false,
    bool requiredField = true,
    int maxLines = 1,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(label),
      TextFormField(
        controller: controller,
        validator: requiredField ? _required : null,
        keyboardType: numeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        style: TextStyle(color: _ink, fontSize: 11),
        decoration: _decoration(hint, icon),
      ),
    ],
  );

  InputDecoration _decoration(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(fontSize: 10, color: _muted),
    prefixIcon: Icon(icon, size: 16, color: _muted),
    filled: true,
    fillColor: Theme.of(context).colorScheme.surface,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(color: _line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(color: _line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(color: _orange, width: 1.2),
    ),
  );

  Widget _chipWrap(
    List<String> options, {
    required Set<String> selected,
    required ValueChanged<String> onSelected,
    bool compact = false,
  }) => Wrap(
    spacing: 6,
    runSpacing: 6,
    children: [
      for (final option in options)
        _smallChoice(
          option,
          selected.contains(option),
          () => onSelected(option),
          compact: compact,
        ),
    ],
  );

  Widget _smallChoice(
    String label,
    bool selected,
    VoidCallback onTap, {
    IconData? icon,
    String? subtitle,
    bool compact = false,
  }) => Material(
    color: selected ? _orange : Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        constraints: BoxConstraints(minHeight: compact ? 29 : 32),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 11,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? _orange : _line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: selected ? Colors.white : _muted),
              const SizedBox(width: 4),
            ],
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : _muted,
                    fontSize: compact ? 9 : 10,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: selected ? Colors.white70 : _muted,
                      fontSize: 7.5,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  Widget _iconButton(IconData icon, String tooltip, VoidCallback onPressed) =>
      SizedBox(
        width: 38,
        height: 38,
        child: IconButton(
          onPressed: onPressed,
          tooltip: tooltip,
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surface,
            side: BorderSide(color: _line),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.zero,
          ),
          icon: Icon(icon, size: 19, color: _ink),
        ),
      );

  Widget _smallTag(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFFFE7E0),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: _orange,
        fontSize: 8,
        fontWeight: FontWeight.w800,
      ),
    ),
  );

  Widget _reviewRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 82,
          child: Text(label, style: TextStyle(color: _muted, fontSize: 9.5)),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: _ink,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );

  bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

class _ContactEditorSheet extends StatefulWidget {
  const _ContactEditorSheet({required this.title});

  final String title;

  @override
  State<_ContactEditorSheet> createState() => _ContactEditorSheetState();
}

class _ContactEditorSheetState extends State<_ContactEditorSheet> {
  static const _orange = Color(0xFFE84012);
  Color get _ink => Theme.of(context).colorScheme.onSurface;
  Color get _muted => Theme.of(context).colorScheme.onSurfaceVariant;
  Color get _line => Theme.of(context).colorScheme.outlineVariant;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _nameError;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Enter a contact name');
      return;
    }
    Navigator.pop(context, {
      'name': name,
      'phone': _phoneController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: (media.size.height - media.viewInsets.bottom) * 0.72,
          ),
          child: Material(
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8D8DE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 17),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            color: _ink,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close_rounded, color: _muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Add a contact for this load.',
                    style: TextStyle(color: _muted, fontSize: 11),
                  ),
                  const SizedBox(height: 17),
                  Text(
                    'Name *',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) {
                      if (_nameError != null) setState(() => _nameError = null);
                    },
                    decoration: _decoration(
                      'Contact name',
                      Icons.person_outline_rounded,
                      errorText: _nameError,
                    ),
                  ),
                  const SizedBox(height: 13),
                  Text(
                    'Phone number',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _save(),
                    decoration: _decoration('Optional', Icons.call_outlined),
                  ),
                  const SizedBox(height: 19),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _muted,
                            side: BorderSide(color: _line),
                            minimumSize: const Size.fromHeight(46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          child: Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: _save,
                          icon: Icon(Icons.add_rounded, size: 18),
                          label: Text('Add contact'),
                          style: FilledButton.styleFrom(
                            backgroundColor: _orange,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(
    String hint,
    IconData icon, {
    String? errorText,
  }) => InputDecoration(
    hintText: hint,
    errorText: errorText,
    hintStyle: TextStyle(color: _muted, fontSize: 11),
    prefixIcon: Icon(icon, size: 18, color: _muted),
    filled: true,
    fillColor: Theme.of(context).colorScheme.surface,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(color: _line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(color: _line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(color: _orange, width: 1.3),
    ),
  );
}

class _StopEditorSheet extends StatefulWidget {
  const _StopEditorSheet({
    required this.stopNumber,
    required this.initialPickup,
    required this.initialDestination,
  });

  final int stopNumber;
  final String initialPickup;
  final String initialDestination;

  @override
  State<_StopEditorSheet> createState() => _StopEditorSheetState();
}

class _StopEditorSheetState extends State<_StopEditorSheet> {
  static const _orange = Color(0xFFE84012);
  Color get _ink => Theme.of(context).colorScheme.onSurface;
  Color get _muted => Theme.of(context).colorScheme.onSurfaceVariant;
  Color get _line => Theme.of(context).colorScheme.outlineVariant;

  final _locationController = TextEditingController();
  final _contactController = TextEditingController();
  final _weightController = TextEditingController();
  String _type = 'drop';

  @override
  void dispose() {
    _locationController.dispose();
    _contactController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _save() {
    final location = _locationController.text.trim();
    if (location.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a stop location.')));
      return;
    }
    final weightText = _weightController.text.trim();
    final weight = weightText.isEmpty ? 0.0 : double.tryParse(weightText);
    if (weight == null || weight < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid drop weight.')),
      );
      return;
    }

    Navigator.of(context).pop({
      'type': _type,
      'location': location,
      'consignee': _contactController.text.trim(),
      'weightTonnes': _type == 'drop' ? weight : 0.0,
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isPickup = _type == 'pickup';
    final suggestions = isPickup
        ? [widget.initialPickup, widget.initialDestination]
        : [widget.initialDestination, widget.initialPickup];

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: (media.size.height - media.viewInsets.bottom) * 0.9,
          ),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            clipBehavior: Clip.antiAlias,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8D8DE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 17),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Stop ${widget.stopNumber} on the way',
                          style: TextStyle(
                            color: _ink,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Close',
                        icon: Icon(Icons.close_rounded, color: _muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Add an extra pickup point or a delivery drop.',
                    style: TextStyle(color: _muted, fontSize: 11),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F1F4),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        _typeButton(
                          'pickup',
                          'Extra pickup',
                          Icons.add_location_alt_outlined,
                        ),
                        _typeButton('drop', 'Drop', Icons.flag_outlined),
                      ],
                    ),
                  ),
                  const SizedBox(height: 17),
                  _fieldLabel(
                    isPickup ? 'Pickup location *' : 'Drop location *',
                  ),
                  TextField(
                    controller: _locationController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: _decoration(
                      isPickup ? 'Enter pickup point' : 'Enter delivery stop',
                      Icons.location_on_outlined,
                    ),
                  ),
                  if (suggestions
                      .where((value) => value.isNotEmpty)
                      .isNotEmpty) ...[
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: suggestions
                          .where((value) => value.isNotEmpty)
                          .toSet()
                          .map(
                            (value) => ActionChip(
                              label: Text(value),
                              onPressed: () => _locationController.text = value,
                              visualDensity: VisualDensity.compact,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surface,
                              side: BorderSide(color: _line),
                              labelStyle: TextStyle(
                                color: _muted,
                                fontSize: 10,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 15),
                  _fieldLabel(isPickup ? 'Pickup contact' : 'Consignee'),
                  TextField(
                    controller: _contactController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: isPickup
                        ? TextInputAction.done
                        : TextInputAction.next,
                    decoration: _decoration(
                      isPickup
                          ? 'Name or phone number'
                          : 'Consignee name or phone',
                      Icons.person_outline_rounded,
                    ),
                  ),
                  if (!isPickup) ...[
                    const SizedBox(height: 15),
                    _fieldLabel('Drop weight (tonnes)'),
                    TextField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.done,
                      decoration: _decoration('Optional', Icons.scale_outlined),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _muted,
                            side: BorderSide(color: _line),
                            minimumSize: const Size.fromHeight(46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          child: Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: _save,
                          icon: Icon(Icons.add_rounded, size: 18),
                          label: Text(
                            isPickup ? 'Add pickup point' : 'Add drop',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: _orange,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _typeButton(String value, String label, IconData icon) {
    final selected = _type == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _type = value),
        borderRadius: BorderRadius.circular(11),
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: selected ? _orange : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: selected ? Colors.white : _muted),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : _muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: TextStyle(color: _ink, fontSize: 11, fontWeight: FontWeight.w700),
    ),
  );

  InputDecoration _decoration(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: _muted, fontSize: 11),
    prefixIcon: Icon(icon, size: 18, color: _muted),
    filled: true,
    fillColor: Theme.of(context).colorScheme.surface,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(color: _line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(color: _line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(color: _orange, width: 1.3),
    ),
  );
}
