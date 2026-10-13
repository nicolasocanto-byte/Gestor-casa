import 'package:flutter/material.dart';

void main() {
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

// MODELOS DE DATOS
class ProductoAlmacen {
  final String nombre;
  final double cantidadPaquete;
  final String unidad; // 'gr', 'kg', 'ml', 'L', 'un'
  final String categoria;

  ProductoAlmacen({
    required this.nombre,
    required this.cantidadPaquete,
    required this.unidad,
    required this.categoria,
  });

  String get descripcionCompleta => '[$categoria] $nombre ($cantidadPaquete $unidad)';
}

class ItemDespensa {
  final String nombre;
  double cantidadActual;
  final String unidad;
  final String categoria;

  ItemDespensa({
    required this.nombre,
    required this.cantidadActual,
    required this.unidad,
    required this.categoria,
  });
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
}

class ItemSimulado {
  final String nombre;
  int cantidadPaquetes;
  final String unidad;
  final String categoria;

  ItemSimulado({
    required this.nombre,
    required this.cantidadPaquetes,
    required this.unidad,
    required this.categoria,
  });
}

// NAVEGACIÓN PRINCIPAL
class PantallaNavegacionPrincipal extends StatefulWidget {
  const PantallaNavegacionPrincipal({super.key});

  @override
  State<PantallaNavegacionPrincipal> createState() => _PantallaNavegacionPrincipalState();
}

class _PantallaNavegacionPrincipalState extends State<PantallaNavegacionPrincipal> {
  int _indicePestana = 0;

  final List<String> _tiendasGuardadas = ['Supermercado Coto', 'Verdulería del Barrio', 'Carrefour'];
  final List<String> _categoriasGuardadas = ['Alimentos', 'Limpieza', 'Bebidas', 'Higiene y Perfumería'];

  final List<ProductoAlmacen> _catalogoAlmacen = [
    ProductoAlmacen(nombre: 'Fideos Moñito', cantidadPaquete: 500, unidad: 'gr', categoria: 'Alimentos'),
    ProductoAlmacen(nombre: 'Leche Entera', cantidadPaquete: 1, unidad: 'L', categoria: 'Bebidas'),
    ProductoAlmacen(nombre: 'Detergente Lavavajillas', cantidadPaquete: 750, unidad: 'ml', categoria: 'Limpieza'),
  ];

  final List<ItemDespensa> _inventarioDespensa = [
    ItemDespensa(nombre: 'Fideos Moñito', cantidadActual: 1000, unidad: 'gr', categoria: 'Alimentos'),
    ItemDespensa(nombre: 'Leche Entera', cantidadActual: 2, unidad: 'L', categoria: 'Bebidas'),
  ];

  final List<TicketCompra> _historicoTickets = [];

  void _ingresarCompra(TicketCompra ticket) {
    setState(() {
      _historicoTickets.add(ticket);

      for (var prod in ticket.productos) {
        final index = _inventarioDespensa.indexWhere(
          (item) => item.nombre.toLowerCase() == prod.nombre.toLowerCase() && item.unidad == prod.unidad,
        );

        if (index >= 0) {
          _inventarioDespensa[index].cantidadActual += prod.cantidadTotalProd;
        } else {
          _inventarioDespensa.add(ItemDespensa(
            nombre: prod.nombre,
            cantidadActual: prod.cantidadTotalProd,
            unidad: prod.unidad,
            categoria: prod.categoria,
          ));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final paginas = [
      RegistroComprasPantalla(
        tiendas: _tiendasGuardadas,
        categorias: _categoriasGuardadas,
        catalogo: _catalogoAlmacen,
        onFinalizarCompra: _ingresarCompra,
      ),
      DespensaConsumoPantalla(
        despensa: _inventarioDespensa,
        categorias: _categoriasGuardadas,
        onActualizar: () => setState(() {}),
      ),
      SimuladorComprasPantalla(
        tiendas: _tiendasGuardadas,
        catalogo: _catalogoAlmacen,
        tickets: _historicoTickets,
      ),
      EstadisticasComparadorPantalla(
        tickets: _historicoTickets,
        categorias: _categoriasGuardadas,
        tiendas: _tiendasGuardadas,
        catalogo: _catalogoAlmacen,
      ),
      GestionCatalogosPantalla(
        tiendas: _tiendasGuardadas,
        categorias: _categoriasGuardadas,
        catalogo: _catalogoAlmacen,
        onActualizar: () => setState(() {}),
      ),
    ];

    return Scaffold(
      body: paginas[_indicePestana],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indicePestana,
        onTap: (index) => setState(() => _indicePestana = index),
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Comprar'),
          BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: 'Despensa'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_checkout), label: 'Simulador'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Estadísticas'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Catálogos'),
        ],
      ),
    );
  }
}

// PESTAÑA 1: REGISTRO DE COMPRAS
class RegistroComprasPantalla extends StatefulWidget {
  final List<String> tiendas;
  final List<String> categorias;
  final List<ProductoAlmacen> catalogo;
  final Function(TicketCompra) onFinalizarCompra;

  const RegistroComprasPantalla({
    super.key,
    required this.tiendas,
    required this.categorias,
    required this.catalogo,
    required this.onFinalizarCompra,
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
  final List<String> _unidadesDisponibles = ['gr', 'kg', 'ml', 'L', 'un'];
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

  void _finalizarYGuardar() {
    if (_productosTicket.isEmpty || _tiendaSeleccionada == null) {
      _mostrarMensaje('Agrega al menos un producto y selecciona una tienda.');
      return;
    }

    final ticket = TicketCompra(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fecha: DateTime.now(),
      tienda: _tiendaSeleccionada!,
      subtotal: _subtotalGeneral,
      montoDescuento: _montoDescuentoTotal,
      totalFinal: _totalConDescuento,
      productos: List.from(_productosTicket),
    );

    widget.onFinalizarCompra(ticket);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Compra guardada en estadísticas y sumada a la Despensa!')),
    );

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
                      onPressed: _finalizarYGuardar,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Finalizar Compra y Sumar a Despensa'),
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

// PESTAÑA 2: DESPENSA Y CONSUMO DIARIO
class DespensaConsumoPantalla extends StatefulWidget {
  final List<ItemDespensa> despensa;
  final List<String> categorias;
  final VoidCallback onActualizar;

  const DespensaConsumoPantalla({
    super.key,
    required this.despensa,
    required this.categorias,
    required this.onActualizar,
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
              onPressed: () {
                final valor = double.tryParse(consumoController.text.trim().replaceAll(',', '.')) ?? 0.0;
                if (valor > 0) {
                  setState(() {
                    item.cantidadActual -= valor;
                    if (item.cantidadActual < 0) item.cantidadActual = 0;
                  });
                  widget.onActualizar();
                  Navigator.pop(context);
                }
              },
              child: const Text('Descontar Stock'),
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

// PESTAÑA 3: SIMULADOR Y COMPARADOR DE CESTA DE COMPRAS
class SimuladorComprasPantalla extends StatefulWidget {
  final List<String> tiendas;
  final List<ProductoAlmacen> catalogo;
  final List<TicketCompra> tickets;

  const SimuladorComprasPantalla({
    super.key,
    required this.tiendas,
    required this.catalogo,
    required this.tickets,
  });

  @override
  State<SimuladorComprasPantalla> createState() => _SimuladorComprasPantallaState();
}

class _SimuladorComprasPantallaState extends State<SimuladorComprasPantalla> {
  ProductoAlmacen? _productoSeleccionado;
  final List<ItemSimulado> _listaSimulada = [];

  void _agregarAListaSimulada(ProductoAlmacen prod) {
    setState(() {
      final idx = _listaSimulada.indexWhere((i) => i.nombre.toLowerCase() == prod.nombre.toLowerCase());
      if (idx >= 0) {
        _listaSimulada[idx].cantidadPaquetes += 1;
      } else {
        _listaSimulada.add(ItemSimulado(
          nombre: prod.nombre,
          cantidadPaquetes: 1,
          unidad: prod.unidad,
          categoria: prod.categoria,
        ));
      }
    });
  }

  double? _obtenerUltimoPrecio(String nombreProd, String tienda) {
    for (var ticket in widget.tickets.reversed) {
      if (ticket.tienda == tienda) {
        for (var p in ticket.productos) {
          if (p.nombre.toLowerCase() == nombreProd.toLowerCase()) {
            return p.precioUnitarioPaquete;
          }
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, double> costoPorTienda = {};
    final Map<String, int> productosFaltantesPorTienda = {};

    for (var tienda in widget.tiendas) {
      double totalTienda = 0.0;
      int faltantes = 0;

      for (var item in _listaSimulada) {
        final precio = _obtenerUltimoPrecio(item.nombre, tienda);
        if (precio != null) {
          totalTienda += precio * item.cantidadPaquetes;
        } else {
          faltantes++;
        }
      }

      costoPorTienda[tienda] = totalTienda;
      productosFaltantesPorTienda[tienda] = faltantes;
    }

    String? tiendaMasBarata;
    double menorCosto = double.infinity;

    costoPorTienda.forEach((tienda, costo) {
      if (costo > 0 && costo < menorCosto && (productosFaltantesPorTienda[tienda] == 0)) {
        menorCosto = costo;
        tiendaMasBarata = tienda;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulador de Cesta de Compras'),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Simular Lista de Compras:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<ProductoAlmacen>(
                      value: _productoSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Agregar producto a la simulación',
                        prefixIcon: Icon(Icons.add_shopping_cart),
                        border: OutlineInputBorder(),
                      ),
                      items: widget.catalogo
                          .map((p) => DropdownMenuItem(value: p, child: Text(p.descripcionCompleta)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          _agregarAListaSimulada(val);
                          setState(() => _productoSeleccionado = null);
                        }
                      },
                      hint: const Text('Seleccionar del catálogo...'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            const Text('Cesta a Cotizar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),

            _listaSimulada.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('Agrega productos arriba para comparar presupuestos entre tiendas.')),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _listaSimulada.length,
                    itemBuilder: (context, index) {
                      final item = _listaSimulada[index];
                      return Card(
                        child: ListTile(
                          title: Text(item.nombre),
                          subtitle: Text('Categoría: ${item.categoria}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  setState(() {
                                    if (item.cantidadPaquetes > 1) {
                                      item.cantidadPaquetes--;
                                    } else {
                                      _listaSimulada.removeAt(index);
                                    }
                                  });
                                },
                              ),
                              Text('x${item.cantidadPaquetes}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => setState(() => item.cantidadPaquetes++),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 16),

            if (_listaSimulada.isNotEmpty) ...[
              const Text('Comparativa de Presupuesto por Tienda:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),

              ...widget.tiendas.map((tienda) {
                final total = costoPorTienda[tienda] ?? 0.0;
                final faltantes = productosFaltantesPorTienda[tienda] ?? 0;
                final esMasBarata = tienda == tiendaMasBarata;

                return Card(
                  color: esMasBarata ? Colors.green.shade50 : null,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(tienda, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                if (esMasBarata) ...[
                                  const SizedBox(width: 8),
                                  Chip(
                                    label: const Text('¡MÁS BARATO!', style: TextStyle(color: Colors.white, fontSize: 11)),
                                    backgroundColor: Colors.green,
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: esMasBarata ? Colors.green.shade800 : Colors.teal,
                              ),
                            ),
                          ],
                        ),
                        if (faltantes > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'Nota: Hay $faltantes producto(s) sin precio histórico en esta tienda.',
                              style: const TextStyle(color: Colors.orange, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

// PESTAÑA 4: ESTADÍSTICAS, COMPARADOR Y FILTROS TEMPORALES
class EstadisticasComparadorPantalla extends StatefulWidget {
  final List<TicketCompra> tickets;
  final List<String> categorias;
  final List<String> tiendas;
  final List<ProductoAlmacen> catalogo;

  const EstadisticasComparadorPantalla({
    super.key,
    required this.tickets,
    required this.categorias,
    required this.tiendas,
    required this.catalogo,
  });

  @override
  State<EstadisticasComparadorPantalla> createState() => _EstadisticasComparadorPantallaState();
}

class _EstadisticasComparadorPantallaState extends State<EstadisticasComparadorPantalla> {
  String _filtroPeriodo = 'Este Mes';
  final List<String> _opcionesPeriodo = ['Esta Semana', 'Este Mes', 'Mes Anterior', 'Todo el Histórico'];

  String? _productoParaComparar;
  String? _tiendaParaComparar;

  // Comparativa de Meses
  String? _mesComparar1;
  String? _mesComparar2;

  List<TicketCompra> get _ticketsFiltrados {
    final ahora = DateTime.now();
    return widget.tickets.where((t) {
      if (_filtroPeriodo == 'Esta Semana') {
        final inicioSemana = ahora.subtract(Duration(days: ahora.weekday - 1));
        final fechaTicketSinHora = DateTime(t.fecha.year, t.fecha.month, t.fecha.day);
        final inicioSemanaSinHora = DateTime(inicioSemana.year, inicioSemana.month, inicioSemana.day);
        return fechaTicketSinHora.isAfter(inicioSemanaSinHora.subtract(const Duration(days: 1)));
      } else if (_filtroPeriodo == 'Este Mes') {
        return t.fecha.year == ahora.year && t.fecha.month == ahora.month;
      } else if (_filtroPeriodo == 'Mes Anterior') {
        final mesAnterior = DateTime(ahora.year, ahora.month - 1);
        return t.fecha.year == mesAnterior.year && t.fecha.month == mesAnterior.month;
      }
      return true; // Todo el histórico
    }).toList();
  }

  double get _gastoTotalFiltrado => _ticketsFiltrados.fold(0, (sum, t) => sum + t.totalFinal);

  Map<String, double> get _gastosPorCategoria {
    final Map<String, double> mapa = {};
    for (var t in _ticketsFiltrados) {
      for (var p in t.productos) {
        mapa[p.categoria] = (mapa[p.categoria] ?? 0) + p.subtotal;
      }
    }
    return mapa;
  }

  Map<String, double> get _gastosPorTienda {
    final Map<String, double> mapa = {};
    for (var t in _ticketsFiltrados) {
      mapa[t.tienda] = (mapa[t.tienda] ?? 0) + t.totalFinal;
    }
    return mapa;
  }

  List<String> get _listaMesesDisponibles {
    final Set<String> meses = {};
    for (var t in widget.tickets) {
      final mesStr = '${t.fecha.month.toString().padLeft(2, '0')}/${t.fecha.year}';
      meses.add(mesStr);
    }
    return meses.toList();
  }

  double _calcularGastoDeUnMes(String? mesAnio) {
    if (mesAnio == null) return 0.0;
    final partes = mesAnio.split('/');
    if (partes.length < 2) return 0.0;
    final mes = int.tryParse(partes[0]) ?? 0;
    final anio = int.tryParse(partes[1]) ?? 0;

    return widget.tickets
        .where((t) => t.fecha.month == mes && t.fecha.year == anio)
        .fold(0.0, (sum, t) => sum + t.totalFinal);
  }

  List<ProductoCompra> get _historialDelProductoSeleccionado {
    if (_productoParaComparar == null) return [];
    final List<ProductoCompra> prods = [];
    for (var t in widget.tickets) {
      for (var p in t.productos) {
        if (p.nombre.toLowerCase() == _productoParaComparar!.toLowerCase()) {
          prods.add(p);
        }
      }
    }
    return prods;
  }

  List<TicketCompra> get _ticketsDelComercioSeleccionado {
    if (_tiendaParaComparar == null) return [];
    final list = widget.tickets.where((t) => t.tienda == _tiendaParaComparar).toList();
    list.sort((a, b) => b.fecha.compareTo(a.fecha));
    return list;
  }

  String _formatearFecha(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final nombresProductos = widget.catalogo.map((p) => p.nombre).toSet();
    for (var t in widget.tickets) {
      for (var p in t.productos) {
        nombresProductos.add(p.nombre);
      }
    }

    final ticketsComercio = _ticketsDelComercioSeleccionado;
    final mesesDisponibles = _listaMesesDisponibles;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Estadísticas y Comparador'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.pie_chart), text: 'Gastos y Períodos'),
              Tab(icon: Icon(Icons.shopping_bag), text: 'Por Producto'),
              Tab(icon: Icon(Icons.receipt), text: 'Por Ticket / Comercio'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // SUB-PESTAÑA 1: GASTOS Y FILTROS POR PERÍODO
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selector de período
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: DropdownButtonFormField<String>(
                        value: _filtroPeriodo,
                        decoration: const InputDecoration(
                          labelText: 'Filtrar Gastos por Período',
                          prefixIcon: Icon(Icons.calendar_month),
                          border: OutlineInputBorder(),
                        ),
                        items: _opcionesPeriodo
                            .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _filtroPeriodo = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tarjeta de gasto total del período
                  Card(
                    color: Colors.teal.shade700,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Gasto ($_filtroPeriodo):', style: const TextStyle(color: Colors.white, fontSize: 16)),
                          Text(
                            '\$${_gastoTotalFiltrado.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // MÓDULO COMPARADOR ENTRE DOS MESES DISTINTOS
                  Card(
                    color: Colors.teal.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Comparar Gastos entre Meses:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _mesComparar1,
                                  decoration: const InputDecoration(labelText: 'Mes A', border: OutlineInputBorder()),
                                  items: mesesDisponibles.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                                  onChanged: (val) => setState(() => _mesComparar1 = val),
                                  hint: const Text('Mes 1'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _mesComparar2,
                                  decoration: const InputDecoration(labelText: 'Mes B', border: OutlineInputBorder()),
                                  items: mesesDisponibles.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                                  onChanged: (val) => setState(() => _mesComparar2 = val),
                                  hint: const Text('Mes 2'),
                                ),
                              ),
                            ],
                          ),
                          if (_mesComparar1 != null && _mesComparar2 != null) ...[
                            const SizedBox(height: 12),
                            Builder(
                              builder: (context) {
                                final gasto1 = _calcularGastoDeUnMes(_mesComparar1);
                                final gasto2 = _calcularGastoDeUnMes(_mesComparar2);
                                final diff = gasto1 - gasto2;
                                final porc = gasto2 > 0 ? (diff / gasto2) * 100 : 0.0;
                                final gastoMayor = diff > 0;

                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Total $_mesComparar1: \$${gasto1.toStringAsFixed(2)}'),
                                        Text('Total $_mesComparar2: \$${gasto2.toStringAsFixed(2)}'),
                                      ],
                                    ),
                                    const Divider(),
                                    Row(
                                      children: [
                                        Icon(
                                          gastoMayor ? Icons.trending_up : Icons.trending_down,
                                          color: gastoMayor ? Colors.red : Colors.green,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Diferencia: ${gastoMayor ? "+" : ""}\$${diff.toStringAsFixed(2)} (${porc.toStringAsFixed(1)}%)',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: gastoMayor ? Colors.red.shade800 : Colors.green.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gastos por Categoría
                  const Text('Gastos por Categoría:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  _gastosPorCategoria.isEmpty
                      ? const Text('Sin compras en este período.')
                      : Column(
                          children: _gastosPorCategoria.entries.map((e) {
                            final porcentaje = _gastoTotalFiltrado > 0 ? (e.value / _gastoTotalFiltrado) : 0.0;
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text('\$${e.value.toStringAsFixed(2)} (${(porcentaje * 100).toStringAsFixed(1)}%)'),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    LinearProgressIndicator(value: porcentaje, minHeight: 8, color: Colors.teal),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 16),

                  // Gastos por Tienda
                  const Text('Gastos por Tienda:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  _gastosPorTienda.isEmpty
                      ? const Text('Sin compras en este período.')
                      : Column(
                          children: _gastosPorTienda.entries.map((e) {
                            final porcentaje = _gastoTotalFiltrado > 0 ? (e.value / _gastoTotalFiltrado) : 0.0;
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text('\$${e.value.toStringAsFixed(2)} (${(porcentaje * 100).toStringAsFixed(1)}%)'),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    LinearProgressIndicator(value: porcentaje, minHeight: 8, color: Colors.orange),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),

            // SUB-PESTAÑA 2: COMPARAR POR PRODUCTO
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: _productoParaComparar,
                    decoration: const InputDecoration(
                      labelText: 'Selecciona Producto para Comparar',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    items: nombresProductos
                        .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                        .toList(),
                    onChanged: (val) => setState(() => _productoParaComparar = val),
                    hint: const Text('Elije un producto...'),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: _historialDelProductoSeleccionado.isEmpty
                        ? const Center(
                            child: Text('Selecciona un producto comprado para ver sus precios entre locales y fechas.'),
                          )
                        : ListView.builder(
                            itemCount: _historialDelProductoSeleccionado.length,
                            itemBuilder: (context, index) {
                              final p = _historialDelProductoSeleccionado[index];

                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.store, color: Colors.teal),
                                  title: Text('${p.lugar} - \$${p.precioUnitarioPaquete.toStringAsFixed(2)}'),
                                  subtitle: Text('Fecha: ${_formatearFecha(p.fecha)} | Paquete: ${p.cantidadPorPaquete} ${p.unidad}'),
                                  trailing: Text(
                                    '\$${(p.precioUnitarioPaquete / p.cantidadPorPaquete).toStringAsFixed(2)} / ${p.unidad}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),

            // SUB-PESTAÑA 3: COMPARAR TICKETS COMPLETOS POR COMERCIO
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: _tiendaParaComparar,
                    decoration: const InputDecoration(
                      labelText: 'Selecciona Comercio para Comparar Tickets',
                      prefixIcon: Icon(Icons.storefront),
                      border: OutlineInputBorder(),
                    ),
                    items: widget.tiendas
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) => setState(() => _tiendaParaComparar = val),
                    hint: const Text('Elije una tienda...'),
                  ),
                  const SizedBox(height: 16),

                  if (ticketsComercio.length >= 2) ...[
                    Card(
                      color: Colors.amber.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Builder(
                          builder: (context) {
                            final ultimo = ticketsComercio[0];
                            final anterior = ticketsComercio[1];
                            final dif = ultimo.totalFinal - anterior.totalFinal;
                            final porc = anterior.totalFinal > 0 ? (dif / anterior.totalFinal) * 100 : 0.0;
                            final subio = dif > 0;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Comparación Última Compra vs Anterior:', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Última (${_formatearFecha(ultimo.fecha)}): \$${ultimo.totalFinal.toStringAsFixed(2)}'),
                                    Text('Anterior (${_formatearFecha(anterior.fecha)}): \$${anterior.totalFinal.toStringAsFixed(2)}'),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  children: [
                                    Icon(
                                      subio ? Icons.trending_up : Icons.trending_down,
                                      color: subio ? Colors.red : Colors.green,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Variación ticket: ${subio ? "+" : ""}\$${dif.toStringAsFixed(2)} (${porc.toStringAsFixed(1)}%)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: subio ? Colors.red.shade800 : Colors.green.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Expanded(
                    child: ticketsComercio.isEmpty
                        ? const Center(
                            child: Text('No hay tickets registrados aún para este comercio.'),
                          )
                        : ListView.builder(
                            itemCount: ticketsComercio.length,
                            itemBuilder: (context, index) {
                              final t = ticketsComercio[index];

                              return Card(
                                child: ExpansionTile(
                                  leading: const Icon(Icons.receipt, color: Colors.teal),
                                  title: Text('Ticket del ${_formatearFecha(t.fecha)}'),
                                  subtitle: Text(
                                    'Total: \$${t.totalFinal.toStringAsFixed(2)} (Subtotal: \$${t.subtotal.toStringAsFixed(2)} | Desc: -\$${t.montoDescuento.toStringAsFixed(2)})',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  children: t.productos.map((prod) {
                                    return ListTile(
                                      dense: true,
                                      title: Text('${prod.nombre} (x${prod.paquetesComprados})'),
                                      subtitle: Text('${prod.cantidadPorPaquete}${prod.unidad} x paq. | Categ: ${prod.categoria}'),
                                      trailing: Text(
                                        '\$${prod.subtotal.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    );
                                  }).toList(),
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

// PESTAÑA 5: GESTIÓN DE TIENDAS, CATEGORÍAS Y CATÁLOGO BASE
class GestionCatalogosPantalla extends StatefulWidget {
  final List<String> tiendas;
  final List<String> categorias;
  final List<ProductoAlmacen> catalogo;
  final VoidCallback onActualizar;

  const GestionCatalogosPantalla({
    super.key,
    required this.tiendas,
    required this.categorias,
    required this.catalogo,
    required this.onActualizar,
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
  final List<String> _unidades = ['gr', 'kg', 'ml', 'L', 'un'];

  void _agregarTienda() {
    final nombre = _tiendaNombreController.text.trim();
    if (nombre.isNotEmpty && !widget.tiendas.contains(nombre)) {
      setState(() {
        widget.tiendas.add(nombre);
        _tiendaNombreController.clear();
      });
      widget.onActualizar();
    }
  }

  void _agregarCategoria() {
    final nombre = _categoriaNombreController.text.trim();
    if (nombre.isNotEmpty && !widget.categorias.contains(nombre)) {
      setState(() {
        widget.categorias.add(nombre);
        _categoriaNombreController.clear();
      });
      widget.onActualizar();
    }
  }

  void _agregarProductoAlmacen() {
    final nombre = _prodNombreController.text.trim();
    final cantidad = double.tryParse(_prodCantidadController.text.trim().replaceAll(',', '.')) ?? 0.0;
    final cat = _prodCategoriaSeleccionada ?? (widget.categorias.isNotEmpty ? widget.categorias.first : 'General');

    if (nombre.isNotEmpty && cantidad > 0) {
      setState(() {
        widget.catalogo.add(ProductoAlmacen(
          nombre: nombre,
          cantidadPaquete: cantidad,
          unidad: _prodUnidad,
          categoria: cat,
        ));
        _prodNombreController.clear();
        _prodCantidadController.clear();
      });
      widget.onActualizar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Administrar Catálogos'),
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
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() => widget.tiendas.removeAt(index));
                                widget.onActualizar();
                              },
                            ),
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
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() => widget.categorias.removeAt(index));
                                widget.onActualizar();
                              },
                            ),
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
                            label: const Text('Guardar en Catálogo'),
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
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() => widget.catalogo.removeAt(index));
                                widget.onActualizar();
                              },
                            ),
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
