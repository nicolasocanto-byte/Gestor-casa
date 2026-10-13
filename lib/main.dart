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

class ProductoCompra {
  final String nombre;
  final String lugar;
  final int paquetesComprados;
  final double cantidadPorPaquete;
  final String unidad;
  final double precioUnitarioPaquete;
  final String categoria;

  ProductoCompra({
    required this.nombre,
    required this.lugar,
    required this.paquetesComprados,
    required this.cantidadPorPaquete,
    required this.unidad,
    required this.precioUnitarioPaquete,
    required this.categoria,
  });

  double get subtotal => paquetesComprados * precioUnitarioPaquete;
  double get cantidadTotalProd => paquetesComprados * cantidadPorPaquete;
}

// NAVEGACIÓN PRINCIPAL
class PantallaNavegacionPrincipal extends StatefulWidget {
  const PantallaNavegacionPrincipal({super.key});

  @override
  State<PantallaNavegacionPrincipal> createState() => _PantallaNavegacionPrincipalState();
}

class _PantallaNavegacionPrincipalState extends State<PantallaNavegacionPrincipal> {
  int _indicePestana = 0;

  // Listas de datos guardados por defecto
  final List<String> _tiendasGuardadas = ['Supermercado Coto', 'Verdulería del Barrio', 'Carrefour'];
  final List<String> _categoriasGuardadas = ['Alimentos', 'Limpieza', 'Bebidas', 'Higiene y Perfumería'];
  
  final List<ProductoAlmacen> _catalogoAlmacen = [
    ProductoAlmacen(nombre: 'Fideos Moñito', cantidadPaquete: 500, unidad: 'gr', categoria: 'Alimentos'),
    ProductoAlmacen(nombre: 'Leche Entera', cantidadPaquete: 1, unidad: 'L', categoria: 'Bebidas'),
    ProductoAlmacen(nombre: 'Detergente Lavavajillas', cantidadPaquete: 750, unidad: 'ml', categoria: 'Limpieza'),
    ProductoAlmacen(nombre: 'Jabón Líquido Ropa', cantidadPaquete: 3, unidad: 'L', categoria: 'Limpieza'),
    ProductoAlmacen(nombre: 'Papel Higiénico (4 rollos)', cantidadPaquete: 4, unidad: 'un', categoria: 'Higiene y Perfumería'),
  ];

  @override
  Widget build(BuildContext context) {
    final paginas = [
      RegistroComprasPantalla(
        tiendas: _tiendasGuardadas,
        categorias: _categoriasGuardadas,
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Registrar Compra'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Tiendas y Almacén'),
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
      _mostrarMensaje('Por favor selecciona o agrega una tienda.');
      return;
    }
    if (nombre.isEmpty || paquetes <= 0 || tamanoPaquete <= 0 || precio <= 0) {
      _mostrarMensaje('Completa nombre, paquetes, contenido y precio.');
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
      ));

      _productoSeleccionado = null;
      _nombreManualController.clear();
      _tamanoPaqueteController.clear();
      _precioPaqueteController.clear();
      _paquetesController.text = '1';
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
        title: const Text('Registro de Compras'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Seleccionar Tienda
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
                  hint: const Text('Elije una tienda guardada'),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Formulario Agregar Producto
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Añadir Producto al Ticket', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),

                    // Filtro por categoría para catálogo
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

                    // Selector del producto guardado
                    DropdownButtonFormField<ProductoAlmacen>(
                      value: _productoSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Cargar desde Almacén',
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

            // Lista de productos del ticket
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

            // Descuento y Totales
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

// PESTAÑA 2: GESTIÓN DE TIENDAS, CATEGORÍAS Y ALMACÉN
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
          title: const Text('Administrar Almacén'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.store), text: 'Tiendas'),
              Tab(icon: Icon(Icons.category), text: 'Categorías'),
              Tab(icon: Icon(Icons.inventory_2), text: 'Catálogo Almacén'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pestaña 1: Tiendas
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
                            labelText: 'Nueva Tienda (ej. Verdulería Don Pedro)',
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

            // Pestaña 2: Categorías
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
                            labelText: 'Nueva Categoría (ej. Mascotas, Baño...)',
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

            // Pestaña 3: Catálogo Almacén
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
                          const Text('Guardar Nuevo Producto en Almacén', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          
                          DropdownButtonFormField<String>(
                            value: _prodCategoriaSeleccionada ?? (widget.categorias.isNotEmpty ? widget.categorias.first : null),
                            decoration: const InputDecoration(
                              labelText: 'Categoría',
                              border: OutlineInputBorder(),
                            ),
                            items: widget.categorias
                                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (val) => setState(() => _prodCategoriaSeleccionada = val),
                          ),
                          const SizedBox(height: 8),

                          TextField(
                            controller: _prodNombreController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre (ej. Lavandina Gel)',
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
                            subtitle: Text('Categoría: ${p.categoria} | Contenido: ${p.cantidadPaquete} ${p.unidad}'),
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
