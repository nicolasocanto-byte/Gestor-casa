import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCJI4y01Hz8MH_s8sajNWEUUkX8E1SHrgc",
      appId: "1:70786421592:web:99af61d76f25c1b044cb2d",
      messagingSenderId: "70786421592",
      projectId: "gestor-casa-3bf3b",
      authDomain: "gestor-casa-3bf3b.firebaseapp.com",
      storageBucket: "gestor-casa-3bf3b.firebasestorage.app",
    ),
  );

  runApp(const MiAppCasa());
}

class MiAppCasa extends StatelessWidget {
  const MiAppCasa({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor Casa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const PantallaNavegacionPrincipal(),
    );
  }
}

// MODELOS CON CONVERSIÓN SEGURA DE TIPOS
class ProductoAlmacen {
  final String id;
  final String nombre;
  final double cantidadPaquete;
  final String unidad;
  final String categoria;

  ProductoAlmacen({
    required this.id,
    required this.nombre,
    required this.cantidadPaquete,
    required this.unidad,
    required this.categoria,
  });

  factory ProductoAlmacen.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return ProductoAlmacen(
      id: doc.id,
      nombre: data?['nombre'] ?? '',
      cantidadPaquete: ((data?['cantidadPaquete'] ?? 0.0) as num).toDouble(),
      unidad: data?['unidad'] ?? 'gr',
      categoria: data?['categoria'] ?? 'General',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'cantidadPaquete': cantidadPaquete,
      'unidad': unidad,
      'categoria': categoria,
    };
  }

  String get descripcionCompleta => '[$categoria] $nombre ($cantidadPaquete $unidad)';
}

class ItemDespensa {
  final String id;
  final String nombre;
  double cantidadActual;
  final String unidad;
  final String categoria;

  ItemDespensa({
    required this.id,
    required this.nombre,
    required this.cantidadActual,
    required this.unidad,
    required this.categoria,
  });

  factory ItemDespensa.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return ItemDespensa(
      id: doc.id,
      nombre: data?['nombre'] ?? '',
      cantidadActual: ((data?['cantidadActual'] ?? 0.0) as num).toDouble(),
      unidad: data?['unidad'] ?? 'gr',
      categoria: data?['categoria'] ?? 'General',
    );
  }
}

class ProductoCompra {
  final String nombre;
  final String lugar;
  final int paquetesComprados;
  final double cantidadPorPaquete;
  final String unidad;
  final double precioUnitarioPaquete;
  final String categoria;
  final DateTime fecha;

  ProductoCompra({
    required this.nombre,
    required this.lugar,
    required this.paquetesComprados,
    required this.cantidadPorPaquete,
    required this.unidad,
    required this.precioUnitarioPaquete,
    required this.categoria,
    required this.fecha,
  });

  double get subtotal => paquetesComprados * precioUnitarioPaquete;
  double get cantidadTotalProd => paquetesComprados * cantidadPorPaquete;

  double get precioPorUnidadBase {
    if (cantidadPorPaquete <= 0) return precioUnitarioPaquete;
    double factor = 1.0;
    if (unidad == 'kg' || unidad == 'L') factor = 1000.0;
    return precioUnitarioPaquete / (cantidadPorPaquete * factor);
  }

  factory ProductoCompra.fromMap(Map<String, dynamic> map) {
    return ProductoCompra(
      nombre: map['nombre'] ?? '',
      lugar: map['lugar'] ?? '',
      paquetesComprados: ((map['paquetesComprados'] ?? 1) as num).toInt(),
      cantidadPorPaquete: ((map['cantidadPorPaquete'] ?? 1.0) as num).toDouble(),
      unidad: map['unidad'] ?? 'gr',
      precioUnitarioPaquete: ((map['precioUnitarioPaquete'] ?? 0.0) as num).toDouble(),
      categoria: map['categoria'] ?? 'General',
      fecha: DateTime.parse(map['fecha'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'lugar': lugar,
      'paquetesComprados': paquetesComprados,
      'cantidadPorPaquete': cantidadPorPaquete,
      'unidad': unidad,
      'precioUnitarioPaquete': precioUnitarioPaquete,
      'categoria': categoria,
      'fecha': fecha.toIso8601String(),
    };
  }
}

class TicketCompra {
  final String id;
  final DateTime fecha;
  final String tienda;
  final double subtotal;
  final double montoDescuento;
  final double totalFinal;
  final List<ProductoCompra> productos;

  TicketCompra({
    required this.id,
    required this.fecha,
    required this.tienda,
    required this.subtotal,
    required this.montoDescuento,
    required this.totalFinal,
    required this.productos,
  });

  factory TicketCompra.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    final prodsRaw = (data?['productos'] as List<dynamic>?) ?? [];
    return TicketCompra(
      id: doc.id,
      fecha: DateTime.parse(data?['fecha'] ?? DateTime.now().toIso8601String()),
      tienda: data?['tienda'] ?? '',
      subtotal: ((data?['subtotal'] ?? 0.0) as num).toDouble(),
      montoDescuento: ((data?['montoDescuento'] ?? 0.0) as num).toDouble(),
      totalFinal: ((data?['totalFinal'] ?? 0.0) as num).toDouble(),
      productos: prodsRaw.map((p) => ProductoCompra.fromMap(p as Map<String, dynamic>)).toList(),
    );
  }

  String get etiquetaVisual => '$tienda - ${fecha.day}/${fecha.month}/${fecha.year} (\$$totalFinal)';
}

// NAVEGACIÓN PRINCIPAL
class PantallaNavegacionPrincipal extends StatefulWidget {
  const PantallaNavegacionPrincipal({super.key});

  @override
  State<PantallaNavegacionPrincipal> createState() => _PantallaNavegacionPrincipalState();
}

class _PantallaNavegacionPrincipalState extends State<PantallaNavegacionPrincipal> {
  int _indicePestana = 0;

  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection('tiendas').snapshots(),
        builder: (context, snapshotTiendas) {
          final tiendas = (snapshotTiendas.hasData && snapshotTiendas.data!.docs.isNotEmpty)
              ? snapshotTiendas.data!.docs.map((d) => (d.data() as Map<String, dynamic>)['nombre'] as String? ?? '').where((s) => s.isNotEmpty).toList()
              : ['Supermercado Coto', 'Carrefour', 'Verdulería del Barrio'];

          return StreamBuilder<QuerySnapshot>(
            stream: db.collection('categorias').snapshots(),
            builder: (context, snapshotCategorias) {
              final categorias = (snapshotCategorias.hasData && snapshotCategorias.data!.docs.isNotEmpty)
                  ? snapshotCategorias.data!.docs.map((d) => (d.data() as Map<String, dynamic>)['nombre'] as String? ?? '').where((s) => s.isNotEmpty).toList()
                  : ['Alimentos', 'Limpieza', 'Bebidas', 'Higiene y Perfumería'];

              return StreamBuilder<QuerySnapshot>(
                stream: db.collection('catalogo').snapshots(),
                builder: (context, snapshotCatalogo) {
                  final catalogo = snapshotCatalogo.hasData
                      ? snapshotCatalogo.data!.docs.map((d) => ProductoAlmacen.fromFirestore(d)).toList()
                      : <ProductoAlmacen>[];

                  return StreamBuilder<QuerySnapshot>(
                    stream: db.collection('despensa').snapshots(),
                    builder: (context, snapshotDespensa) {
                      final despensa = snapshotDespensa.hasData
                          ? snapshotDespensa.data!.docs.map((d) => ItemDespensa.fromFirestore(d)).toList()
                          : <ItemDespensa>[];

                      return StreamBuilder<QuerySnapshot>(
                        stream: db.collection('tickets').snapshots(),
                        builder: (context, snapshotTickets) {
                          final tickets = snapshotTickets.hasData
                              ? snapshotTickets.data!.docs.map((d) => TicketCompra.fromFirestore(d)).toList()
                              : <TicketCompra>[];

                          final paginas = [
                            RegistroComprasPantalla(tiendas: tiendas, categorias: categorias, catalogo: catalogo),
                            DespensaConsumoPantalla(despensa: despensa, categorias: categorias),
                            SimuladorComprasExcelPantalla(tiendas: tiendas, categorias: categorias, catalogo: catalogo),
                            ComparadorTicketsExcelPantalla(tickets: tickets),
                            GestionCatalogosPantalla(tiendas: tiendas, categorias: categorias, catalogo: catalogo),
                          ];

                          return paginas[_indicePestana];
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indicePestana,
        onTap: (index) => setState(() => _indicePestana = index),
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Comprar'),
          BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: 'Despensa'),
          BottomNavigationBarItem(icon: Icon(Icons.table_chart), label: 'Simulador Excel'),
          BottomNavigationBarItem(icon: Icon(Icons.compare), label: 'Comparar Tickets'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Catálogos'),
        ],
      ),
    );
  }
}

// PESTAÑA 1: REGISTRO DE COMPRAS CON SYNC FIREBASE
class RegistroComprasPantalla extends StatefulWidget {
  final List<String> tiendas;
  final List<String> categorias;
  final List<ProductoAlmacen> catalogo;

  const RegistroComprasPantalla({
    super.key,
    required this.tiendas,
    required this.categorias,
    required this.catalogo,
  });

  @override
  State<RegistroComprasPantalla> createState() => _RegistroComprasPantallaState();
}

class _RegistroComprasPantallaState extends State<RegistroComprasPantalla> {
  String? _tiendaSeleccionada;
  String? _categoriaFiltro;
  ProductoAlmacen? _productoSeleccionado;

  final _nombreManualController = TextEditingController();
  final _paquetesController = TextEditingController(text: '1');
  final _tamanoPaqueteController = TextEditingController();
  final _precioPaqueteController = TextEditingController();
  final _descuentoController = TextEditingController();

  String _unidadSeleccionada = 'gr';
  String _categoriaSeleccionada = 'Alimentos';
  final List<String> _unidadesDisponibles = ['gr', 'kg', 'ml', 'L', 'un', 'mts'];
  final List<ProductoCompra> _productosTicket = [];
  bool _descuentoEnPorcentaje = true;

  void _alSeleccionarProducto(ProductoAlmacen? prod) {
    if (prod != null) {
      setState(() {
        _productoSeleccionado = prod;
        _nombreManualController.text = prod.nombre;
        _tamanoPaqueteController.text = prod.cantidadPaquete.toString();
        _unidadSeleccionada = prod.unidad;
        _categoriaSeleccionada = prod.categoria;
      });
    }
  }

  void _agregarProducto() {
    final tienda = _tiendaSeleccionada;
    final nombre = _nombreManualController.text.trim();
    final paquetes = int.tryParse(_paquetesController.text.trim()) ?? 0;
    final tamanoPaquete = double.tryParse(_tamanoPaqueteController.text.trim().replaceAll(',', '.')) ?? 0.0;
    final precio = double.tryParse(_precioPaqueteController.text.trim().replaceAll(',', '.')) ?? 0.0;

    if (tienda == null || tienda.isEmpty) {
      _mostrarMensaje('Selecciona una tienda primero.');
      return;
    }
    if (nombre.isEmpty || paquetes <= 0 || tamanoPaquete <= 0 || precio <= 0) {
      _mostrarMensaje('Completa nombre, cantidad, contenido y precio.');
      return;
    }

    setState(() {
      _productosTicket.add(ProductoCompra(
        nombre: nombre,
        lugar: tienda,
        paquetesComprados: paquetes,
        cantidadPorPaquete: tamanoPaquete,
        unidad: _unidadSeleccionada,
        precioUnitarioPaquete: precio,
        categoria: _categoriaSeleccionada,
        fecha: DateTime.now(),
      ));

      _productoSeleccionado = null;
      _nombreManualController.clear();
      _tamanoPaqueteController.clear();
      _precioPaqueteController.clear();
      _paquetesController.text = '1';
    });
  }

  void _finalizarYGuardarEnNube() async {
    if (_productosTicket.isEmpty || _tiendaSeleccionada == null) {
      _mostrarMensaje('Agrega al menos un producto y selecciona una tienda.');
      return;
    }

    final db = FirebaseFirestore.instance;

    await db.collection('tickets').add({
      'fecha': DateTime.now().toIso8601String(),
      'tienda': _tiendaSeleccionada!,
      'subtotal': _subtotalGeneral,
      'montoDescuento': _montoDescuentoTotal,
      'totalFinal': _totalConDescuento,
      'productos': _productosTicket.map((p) => p.toMap()).toList(),
    });

    for (var prod in _productosTicket) {
      final query = await db
          .collection('despensa')
          .where('nombre', isEqualTo: prod.nombre)
          .where('unidad', isEqualTo: prod.unidad)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final stockActual = ((doc.data()['cantidadActual'] ?? 0.0) as num).toDouble();
        await db.collection('despensa').doc(doc.id).update({
          'cantidadActual': stockActual + prod.cantidadTotalProd,
        });
      } else {
        await db.collection('despensa').add({
          'nombre': prod.nombre,
          'cantidadActual': prod.cantidadTotalProd,
          'unidad': prod.unidad,
          'categoria': prod.categoria,
        });
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Compra guardada y sincronizada en la nube!')),
      );
    }

    setState(() {
      _productosTicket.clear();
      _descuentoController.clear();
    });
  }

  void _mostrarMensaje(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  double get _subtotalGeneral => _productosTicket.fold(0, (sum, item) => sum + item.subtotal);

  double get _valorDescuento => double.tryParse(_descuentoController.text.trim().replaceAll(',', '.')) ?? 0.0;

  double get _montoDescuentoTotal {
    if (_subtotalGeneral == 0) return 0.0;
    double desc = _descuentoEnPorcentaje ? _subtotalGeneral * (_valorDescuento / 100) : _valorDescuento;
    return desc > _subtotalGeneral ? _subtotalGeneral : desc;
  }

  double get _totalConDescuento => _subtotalGeneral - _montoDescuentoTotal;

  double _calcularPrecioFinalPorPaquete(ProductoCompra prod) {
    if (_subtotalGeneral == 0) return prod.precioUnitarioPaquete;
    final proporcion = prod.subtotal / _subtotalGeneral;
    final descuentoProd = _montoDescuentoTotal * proporcion;
    return (prod.subtotal - descuentoProd) / prod.paquetesComprados;
  }

  List<ProductoAlmacen> get _productosFiltrados {
    if (_categoriaFiltro == null || _categoriaFiltro == 'Todas') {
      return widget.catalogo;
    }
    return widget.catalogo.where((p) => p.categoria == _categoriaFiltro).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Compra'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: DropdownButtonFormField<String>(
                  value: _tiendaSeleccionada,
                  decoration: const InputDecoration(
                    labelText: 'Seleccionar Tienda / Comercio',
                    prefixIcon: Icon(Icons.store),
                    border: OutlineInputBorder(),
                  ),
                  items: widget.tiendas.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => setState(() => _tiendaSeleccionada = val),
                  hint: const Text('Elije una tienda'),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Añadir Producto al Ticket', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _categoriaFiltro ?? 'Todas',
                            decoration: const InputDecoration(
                              labelText: 'Filtrar Catálogo',
                              prefixIcon: Icon(Icons.filter_list),
                              border: OutlineInputBorder(),
                            ),
                            items: ['Todas', ...widget.categorias]
                                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (val) => setState(() {
                              _categoriaFiltro = val;
                              _productoSeleccionado = null;
                            }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    DropdownButtonFormField<ProductoAlmacen>(
                      value: _productoSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Cargar desde Catálogo',
                        prefixIcon: Icon(Icons.inventory),
                        border: OutlineInputBorder(),
                      ),
                      items: _productosFiltrados
                          .map((p) => DropdownMenuItem(value: p, child: Text(p.descripcionCompleta)))
                          .toList(),
                      onChanged: _alSeleccionarProducto,
                      hint: const Text('Buscar producto guardado...'),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: _nombreManualController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Producto',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _tamanoPaqueteController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Contenido c/u',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: _unidadSeleccionada,
                            decoration: const InputDecoration(labelText: 'Unid.', border: OutlineInputBorder()),
                            items: _unidadesDisponibles
                                .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _unidadSeleccionada = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _paquetesController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Cant. Paquetes',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _precioPaqueteController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Precio x Paq. (\$)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    ElevatedButton.icon(
                      onPressed: _agregarProducto,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Agregar al Ticket'),
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(45)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            const Text('Productos en el Ticket:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),

            _productosTicket.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('El ticket está vacío.')),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _productosTicket.length,
                    itemBuilder: (context, index) {
                      final prod = _productosTicket[index];
                      final precioFinalPaquete = _calcularPrecioFinalPorPaquete(prod);

                      return Card(
                        child: ListTile(
                          title: Text('[${prod.categoria}] ${prod.nombre} (x${prod.paquetesComprados})'),
                          subtitle: Text(
                            'Original: \$${prod.precioUnitarioPaquete.toStringAsFixed(2)} c/u\n'
                            'Con desc.: \$${precioFinalPaquete.toStringAsFixed(2)} c/u (${prod.cantidadTotalProd} ${prod.unidad} total)',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '\$${(precioFinalPaquete * prod.paquetesComprados).toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => setState(() => _productosTicket.removeAt(index)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 12),

            Card(
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _descuentoController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              labelText: _descuentoEnPorcentaje ? 'Descuento (%)' : 'Descuento (\$)',
                              prefixIcon: const Icon(Icons.discount),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment(value: true, label: Text('%')),
                              ButtonSegment(value: false, label: Text('\$')),
                            ],
                            selected: {_descuentoEnPorcentaje},
                            onSelectionChanged: (val) => setState(() => _descuentoEnPorcentaje = val.first),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal:'),
                        Text('\$${_subtotalGeneral.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_descuentoEnPorcentaje ? 'Descuento (${_valorDescuento.toStringAsFixed(1)}%):' : 'Descuento Fijo:'),
                        Text('-\$${_montoDescuentoTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, color: Colors.green)),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TOTAL FINAL:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(
                          '\$${_totalConDescuento.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _finalizarYGuardarEnNube,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('Finalizar Compra y Sincronizar en Nube'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// PESTAÑA 2: DESPENSA CON DESCUENTO DE STOCK EN NUBE
class DespensaConsumoPantalla extends StatefulWidget {
  final List<ItemDespensa> despensa;
  final List<String> categorias;

  const DespensaConsumoPantalla({
    super.key,
    required this.despensa,
    required this.categorias,
  });

  @override
  State<DespensaConsumoPantalla> createState() => _DespensaConsumoPantallaState();
}

class _DespensaConsumoPantallaState extends State<DespensaConsumoPantalla> {
  String? _filtroCategoria;

  void _abrirModalConsumo(ItemDespensa item) {
    final consumoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Consumir: ${item.nombre}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Stock actual: ${item.cantidadActual.toStringAsFixed(1)} ${item.unidad}'),
              const SizedBox(height: 12),
              TextField(
                controller: consumoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Cantidad a descontar (${item.unidad})',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final valor = double.tryParse(consumoController.text.trim().replaceAll(',', '.')) ?? 0.0;
                if (valor > 0) {
                  double nuevoStock = item.cantidadActual - valor;
                  if (nuevoStock < 0) nuevoStock = 0;

                  await FirebaseFirestore.instance.collection('despensa').doc(item.id).update({
                    'cantidadActual': nuevoStock,
                  });

                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Descontar en Nube'),
            ),
          ],
        );
      },
    );
  }

  List<ItemDespensa> get _itemsFiltrados {
    if (_filtroCategoria == null || _filtroCategoria == 'Todas') {
      return widget.despensa;
    }
    return widget.despensa.where((i) => i.categoria == _filtroCategoria).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock de la Despensa'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _filtroCategoria ?? 'Todas',
              decoration: const InputDecoration(
                labelText: 'Filtrar por Categoría',
                prefixIcon: Icon(Icons.filter_list),
                border: OutlineInputBorder(),
              ),
              items: ['Todas', ...widget.categorias]
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _filtroCategoria = val),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: _itemsFiltrados.isEmpty
                  ? const Center(child: Text('No hay productos en la despensa.'))
                  : ListView.builder(
                      itemCount: _itemsFiltrados.length,
                      itemBuilder: (context, index) {
                        final item = _itemsFiltrados[index];
                        final sinStock = item.cantidadActual <= 0;

                        return Card(
                          color: sinStock ? Colors.red.shade50 : null,
                          child: ListTile(
                            leading: Icon(
                              sinStock ? Icons.warning_amber_rounded : Icons.kitchen,
                              color: sinStock ? Colors.red : Colors.teal,
                              size: 32,
                            ),
                            title: Text(
                              item.nombre,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: sinStock ? Colors.red : Colors.black,
                              ),
                            ),
                            subtitle: Text('Categoría: ${item.categoria}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  sinStock ? 'AGOTADO' : '${item.cantidadActual.toStringAsFixed(1)} ${item.unidad}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: sinStock ? Colors.red : Colors.teal.shade800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                    minimumSize: const Size(60, 28),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () => _abrirModalConsumo(item),
                                  icon: const Icon(Icons.remove, size: 16),
                                  label: const Text('Consumir', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// PESTAÑA 3: SIMULADOR EXCEL MULTITIENDA
class SimuladorComprasExcelPantalla extends StatefulWidget {
  final List<String> tiendas;
  final List<String> categorias;
  final List<ProductoAlmacen> catalogo;

  const SimuladorComprasExcelPantalla({
    super.key,
    required this.tiendas,
    required this.categorias,
    required this.catalogo,
  });

  @override
  State<SimuladorComprasExcelPantalla> createState() => _SimuladorComprasExcelPantallaState();
}

class _DatosCeldaSimulador {
  double? precio;
  double? cantidadContenido;
  String unidad;

  _DatosCeldaSimulador({this.precio, this.cantidadContenido, this.unidad = 'gr'});

  double? get precioUnitarioBase {
    if (precio == null || cantidadContenido == null || cantidadContenido! <= 0) return null;
    double factor = 1.0;
    if (unidad == 'kg' || unidad == 'L') factor = 1000.0;
    return precio! / (cantidadContenido! * factor);
  }
}

class _SimuladorComprasExcelPantallaState extends State<SimuladorComprasExcelPantalla> {
  int _cantidadColumnas = 2;
  late List<String?> _tiendasSeleccionadas;

  final Map<String, _DatosCeldaSimulador> _matrizPrecios = {};

  final List<Color> _coloresCategorias = [
    Colors.orange.shade100,
    Colors.blue.shade100,
    Colors.purple.shade100,
    Colors.pink.shade100,
    Colors.teal.shade100,
    Colors.amber.shade100,
  ];

  @override
  void initState() {
    super.initState();
    _tiendasSeleccionadas = [
      widget.tiendas.isNotEmpty ? widget.tiendas[0] : 'Tienda 1',
      widget.tiendas.length > 1 ? widget.tiendas[1] : 'Tienda 2',
      null,
      null,
    ];
  }

  Color _obtenerColorCategoria(String cat) {
    final idx = widget.categorias.indexOf(cat);
    if (idx >= 0) return _coloresCategorias[idx % _coloresCategorias.length];
    return Colors.grey.shade200;
  }

  void _abrirModalIngresoPrecio(ProductoAlmacen prod, int colIndex) {
    final clave = '${prod.nombre}_$colIndex';
    final celdaActual = _matrizPrecios[clave] ?? _DatosCeldaSimulador(cantidadContenido: prod.cantidadPaquete, unidad: prod.unidad);

    final precioCtrl = TextEditingController(text: celdaActual.precio?.toString() ?? '');
    final cantCtrl = TextEditingController(text: celdaActual.cantidadContenido?.toString() ?? prod.cantidadPaquete.toString());
    String unidadSel = celdaActual.unidad;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ingresar en ${_tiendasSeleccionadas[colIndex] ?? "Tienda ${colIndex + 1}"}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Producto: ${prod.nombre}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: precioCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Precio del Paquete/Unidad (\$)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: cantCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Contenido/Medida',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: ['gr', 'kg', 'ml', 'L', 'un', 'mts'].contains(unidadSel) ? unidadSel : 'gr',
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: ['gr', 'kg', 'ml', 'L', 'un', 'mts']
                          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (u) {
                        if (u != null) unidadSel = u;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final p = double.tryParse(precioCtrl.text.trim().replaceAll(',', '.')) ?? 0.0;
                final c = double.tryParse(cantCtrl.text.trim().replaceAll(',', '.')) ?? 0.0;

                setState(() {
                  if (p > 0 && c > 0) {
                    _matrizPrecios[clave] = _DatosCeldaSimulador(
                      precio: p,
                      cantidadContenido: c,
                      unidad: unidadSel,
                    );
                  } else {
                    _matrizPrecios.remove(clave);
                  }
                });
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulador Excel Multitienda'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Cantidad de Comercios:', style: TextStyle(fontWeight: FontWeight.bold)),
                        SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(value: 2, label: Text('2')),
                            ButtonSegment(value: 3, label: Text('3')),
                            ButtonSegment(value: 4, label: Text('4')),
                          ],
                          selected: {_cantidadColumnas},
                          onSelectionChanged: (val) {
                            setState(() => _cantidadColumnas = val.first);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(Colors.teal.shade100),
                    columnSpacing: 16,
                    dataRowMinHeight: 48,
                    columns: [
                      const DataColumn(label: Text('Productos (Despensa)', style: TextStyle(fontWeight: FontWeight.bold))),
                      for (int col = 0; col < _cantidadColumnas; col++)
                        DataColumn(
                          label: SizedBox(
                            width: 140,
                            child: DropdownButtonFormField<String>(
                              value: _tiendasSeleccionadas[col],
                              isExpanded: true,
                              decoration: const InputDecoration(border: InputBorder.none),
                              items: widget.tiendas
                                  .map((t) => DropdownMenuItem(value: t, child: Text(t, overflow: TextOverflow.ellipsis)))
                                  .toList(),
                              onChanged: (val) => setState(() => _tiendasSeleccionadas[col] = val),
                              hint: Text('Tienda ${col + 1}'),
                            ),
                          ),
                        ),
                    ],
                    rows: _generarFilasExcel(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DataRow> _generarFilasExcel() {
    final List<DataRow> filas = [];

    final Map<String, List<ProductoAlmacen>> porCategoria = {};
    for (var prod in widget.catalogo) {
      porCategoria.putIfAbsent(prod.categoria, () => []).add(prod);
    }

    porCategoria.forEach((categoria, productos) {
      filas.add(
        DataRow(
          color: MaterialStateProperty.all(_obtenerColorCategoria(categoria)),
          cells: [
            DataCell(
              Text(
                'CATEGORÍA: ${categoria.toUpperCase()}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
              ),
            ),
            for (int col = 0; col < _cantidadColumnas; col++) const DataCell(Text('')),
          ],
        ),
      );

      for (var prod in productos) {
        double? menorPrecioBase = double.infinity;
        double? mayorPrecioBase = -1.0;

        for (int col = 0; col < _cantidadColumnas; col++) {
          final c = _matrizPrecios['${prod.nombre}_$col'];
          final pb = c?.precioUnitarioBase;
          if (pb != null) {
            if (pb < menorPrecioBase!) menorPrecioBase = pb;
            if (pb > mayorPrecioBase!) mayorPrecioBase = pb;
          }
        }

        if (menorPrecioBase == double.infinity) menorPrecioBase = null;
        if (mayorPrecioBase == -1.0) mayorPrecioBase = null;

        filas.add(
          DataRow(
            cells: [
              DataCell(
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(prod.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Base: ${prod.cantidadPaquete} ${prod.unidad}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              for (int col = 0; col < _cantidadColumnas; col++)
                DataCell(
                  Builder(
                    builder: (context) {
                      final clave = '${prod.nombre}_$col';
                      final celda = _matrizPrecios[clave];

                      Color fondoCelda = Colors.transparent;
                      Color textoColor = Colors.black;

                      if (celda != null && celda.precioUnitarioBase != null && menorPrecioBase != null) {
                        if ((celda.precioUnitarioBase! - menorPrecioBase).abs() < 0.0001) {
                          fondoCelda = Colors.green.shade100;
                          textoColor = Colors.green.shade900;
                        } else if (mayorPrecioBase != null && (celda.precioUnitarioBase! - mayorPrecioBase).abs() < 0.0001) {
                          fondoCelda = Colors.red.shade100;
                          textoColor = Colors.red.shade900;
                        }
                      }

                      return InkWell(
                        onTap: () => _abrirModalIngresoPrecio(prod, col),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: fondoCelda,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: celda == null
                              ? const Text('+ Cargar', style: TextStyle(color: Colors.grey, fontSize: 12))
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '\$${celda.precio!.toStringAsFixed(2)}',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: textoColor),
                                    ),
                                    Text(
                                      '${celda.cantidadContenido}${celda.unidad}',
                                      style: TextStyle(fontSize: 10, color: textoColor),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      }
    });

    return filas;
  }
}

// PESTAÑA 4: COMPARADOR DE TICKETS
class ComparadorTicketsExcelPantalla extends StatefulWidget {
  final List<TicketCompra> tickets;

  const ComparadorTicketsExcelPantalla({
    super.key,
    required this.tickets,
  });

  @override
  State<ComparadorTicketsExcelPantalla> createState() => _ComparadorTicketsExcelPantallaState();
}

class _ComparadorTicketsExcelPantallaState extends State<ComparadorTicketsExcelPantalla> {
  TicketCompra? _ticketA;
  TicketCompra? _ticketB;

  @override
  Widget build(BuildContext context) {
    final Set<String> nombresProductos = {};
    if (_ticketA != null) {
      for (var p in _ticketA!.productos) {
        nombresProductos.add(p.nombre);
      }
    }
    if (_ticketB != null) {
      for (var p in _ticketB!.productos) {
        nombresProductos.add(p.nombre);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparador de Tickets Excel'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<TicketCompra>(
                            value: _ticketA,
                            decoration: const InputDecoration(
                              labelText: 'Columna A: Seleccionar Ticket 1',
                              border: OutlineInputBorder(),
                            ),
                            items: widget.tickets
                                .map((t) => DropdownMenuItem(value: t, child: Text(t.etiquetaVisual, overflow: TextOverflow.ellipsis)))
                                .toList(),
                            onChanged: (val) => setState(() => _ticketA = val),
                            hint: const Text('Elegir Ticket 1'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<TicketCompra>(
                            value: _ticketB,
                            decoration: const InputDecoration(
                              labelText: 'Columna B: Seleccionar Ticket 2',
                              border: OutlineInputBorder(),
                            ),
                            items: widget.tickets
                                .map((t) => DropdownMenuItem(value: t, child: Text(t.etiquetaVisual, overflow: TextOverflow.ellipsis)))
                                .toList(),
                            onChanged: (val) => setState(() => _ticketB = val),
                            hint: const Text('Elegir Ticket 2'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: (_ticketA == null && _ticketB == null)
                ? const Center(child: Text('Selecciona dos tickets arriba para comparar.'))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(Colors.teal.shade100),
                          columnSpacing: 20,
                          columns: [
                            const DataColumn(label: Text('Producto', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text(_ticketA?.tienda ?? 'Ticket A', style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text(_ticketB?.tienda ?? 'Ticket B', style: const TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: nombresProductos.map((prodNombre) {
                            ProductoCompra? prodA;
                            ProductoCompra? prodB;

                            if (_ticketA != null) {
                              try {
                                prodA = _ticketA!.productos.firstWhere((p) => p.nombre.toLowerCase() == prodNombre.toLowerCase());
                              } catch (_) {}
                            }
                            if (_ticketB != null) {
                              try {
                                prodB = _ticketB!.productos.firstWhere((p) => p.nombre.toLowerCase() == prodNombre.toLowerCase());
                              } catch (_) {}
                            }

                            final enAmbos = (prodA != null && prodB != null);
                            Color fondoA = Colors.transparent;
                            Color fondoB = Colors.transparent;

                            if (enAmbos) {
                              if (prodA!.precioPorUnidadBase < prodB!.precioPorUnidadBase) {
                                fondoA = Colors.green.shade100;
                                fondoB = Colors.red.shade100;
                              } else if (prodA.precioPorUnidadBase > prodB.precioPorUnidadBase) {
                                fondoA = Colors.red.shade100;
                                fondoB = Colors.green.shade100;
                              }
                            } else {
                              if (prodA != null) fondoA = Colors.grey.shade200;
                              if (prodB != null) fondoB = Colors.grey.shade200;
                            }

                            return DataRow(
                              cells: [
                                DataCell(Text(prodNombre, style: const TextStyle(fontWeight: FontWeight.bold))),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(color: fondoA, borderRadius: BorderRadius.circular(4)),
                                    child: prodA == null
                                        ? const Text('-', style: TextStyle(color: Colors.grey))
                                        : Text(
                                            '\$${prodA.precioUnitarioPaquete.toStringAsFixed(2)} (${prodA.cantidadPorPaquete}${prodA.unidad})',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: enAmbos ? (fondoA == Colors.green.shade100 ? Colors.green.shade900 : Colors.red.shade900) : Colors.black54,
                                            ),
                                          ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(color: fondoB, borderRadius: BorderRadius.circular(4)),
                                    child: prodB == null
                                        ? const Text('-', style: TextStyle(color: Colors.grey))
                                        : Text(
                                            '\$${prodB.precioUnitarioPaquete.toStringAsFixed(2)} (${prodB.cantidadPorPaquete}${prodB.unidad})',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: enAmbos ? (fondoB == Colors.green.shade100 ? Colors.green.shade900 : Colors.red.shade900) : Colors.black54,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// PESTAÑA 5: GESTIÓN DE TIENDAS Y CATÁLOGOS CON FIREBASE
class GestionCatalogosPantalla extends StatefulWidget {
  final List<String> tiendas;
  final List<String> categorias;
  final List<ProductoAlmacen> catalogo;

  const GestionCatalogosPantalla({
    super.key,
    required this.tiendas,
    required this.categorias,
    required this.catalogo,
  });

  @override
  State<GestionCatalogosPantalla> createState() => _GestionCatalogosPantallaState();
}

class _GestionCatalogosPantallaState extends State<GestionCatalogosPantalla> {
  final _tiendaNombreController = TextEditingController();
  final _categoriaNombreController = TextEditingController();

  final _prodNombreController = TextEditingController();
  final _prodCantidadController = TextEditingController();
  String _prodUnidad = 'gr';
  String? _prodCategoriaSeleccionada;
  final List<String> _unidades = ['gr', 'kg', 'ml', 'L', 'un', 'mts'];

  void _agregarTienda() async {
    final nombre = _tiendaNombreController.text.trim();
    if (nombre.isNotEmpty) {
      await FirebaseFirestore.instance.collection('tiendas').add({'nombre': nombre});
      _tiendaNombreController.clear();
    }
  }

  void _agregarCategoria() async {
    final nombre = _categoriaNombreController.text.trim();
    if (nombre.isNotEmpty) {
      await FirebaseFirestore.instance.collection('categorias').add({'nombre': nombre});
      _categoriaNombreController.clear();
    }
  }

  void _agregarProductoAlmacen() async {
    final nombre = _prodNombreController.text.trim();
    final cantidad = double.tryParse(_prodCantidadController.text.trim().replaceAll(',', '.')) ?? 0.0;
    final cat = _prodCategoriaSeleccionada ?? (widget.categorias.isNotEmpty ? widget.categorias.first : 'General');

    if (nombre.isNotEmpty && cantidad > 0) {
      await FirebaseFirestore.instance.collection('catalogo').add({
        'nombre': nombre,
        'cantidadPaquete': cantidad,
        'unidad': _prodUnidad,
        'categoria': cat,
      });
      _prodNombreController.clear();
      _prodCantidadController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Administrar Catálogos (Nube)'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.store), text: 'Tiendas'),
              Tab(icon: Icon(Icons.category), text: 'Categorías'),
              Tab(icon: Icon(Icons.inventory_2), text: 'Catálogo Base'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _tiendaNombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nueva Tienda',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _agregarTienda,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.tiendas.length,
                      itemBuilder: (context, index) {
                        final t = widget.tiendas[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.store),
                            title: Text(t),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _categoriaNombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nueva Categoría',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _agregarCategoria,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.categorias.length,
                      itemBuilder: (context, index) {
                        final cat = widget.categorias[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.category),
                            title: Text(cat),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Guardar Nuevo Producto Base', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _prodCategoriaSeleccionada ?? (widget.categorias.isNotEmpty ? widget.categorias.first : null),
                            decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
                            items: widget.categorias
                                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (val) => setState(() => _prodCategoriaSeleccionada = val),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _prodNombreController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre Producto',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: _prodCantidadController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(
                                    labelText: 'Contenido Base',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: DropdownButtonFormField<String>(
                                  value: _prodUnidad,
                                  decoration: const InputDecoration(border: OutlineInputBorder()),
                                  items: _unidades.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _prodUnidad = val);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: _agregarProductoAlmacen,
                            icon: const Icon(Icons.save),
                            label: const Text('Guardar en Catálogo Nube'),
                            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.catalogo.length,
                      itemBuilder: (context, index) {
                        final p = widget.catalogo[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.inventory_2),
                            title: Text(p.nombre),
                            subtitle: Text('Categoría: ${p.categoria} | Base: ${p.cantidadPaquete} ${p.unidad}'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
