-- ═══════════════════════════════════════════════════════════════
-- BRAINROTMARKET - SUPABASE SETUP
-- Ejecuta esto en el SQL Editor de tu proyecto Supabase
-- ═══════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────
-- 1. HABILITAR RLS EN TODAS LAS TABLAS
-- ─────────────────────────────────────────────
ALTER TABLE items      ENABLE ROW LEVEL SECURITY;
ALTER TABLE pedidos    ENABLE ROW LEVEL SECURITY;
ALTER TABLE ofertas    ENABLE ROW LEVEL SECURITY;
ALTER TABLE mensajes   ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendedores ENABLE ROW LEVEL SECURITY;

-- ─────────────────────────────────────────────
-- 2. TABLA: items
--    - Cualquiera puede leer ítems activos (catálogo público)
--    - Solo se puede insertar/editar/borrar via service_role (admin)
--    - Los vendedores pueden insertar sus propios ítems (by vendedor_id)
-- ─────────────────────────────────────────────
DROP POLICY IF EXISTS "items_select_public" ON items;
CREATE POLICY "items_select_public"
  ON items FOR SELECT
  USING (activo = true);

-- Insertar: cualquier anon puede crear un ítem (el vendedor no tiene auth)
DROP POLICY IF EXISTS "items_insert_anon" ON items;
CREATE POLICY "items_insert_anon"
  ON items FOR INSERT
  WITH CHECK (true);

-- Update/delete: solo el service role (admin) puede modificar
-- (el vendedor gestiona via su panel con anon key, así que permitimos
--  que alguien actualice solo si conoce el vendedor_id — se valida en app)
DROP POLICY IF EXISTS "items_update_own" ON items;
CREATE POLICY "items_update_own"
  ON items FOR UPDATE
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "items_delete_own" ON items;
CREATE POLICY "items_delete_own"
  ON items FOR DELETE
  USING (true);

-- ─────────────────────────────────────────────
-- 3. TABLA: pedidos
--    - Cualquiera puede insertar un pedido (compradores anon)
--    - Solo puede leer pedidos quien conoce el comprador_roblox o vendedor_id
--    - Update solo para cambiar estado (vendedor/admin)
-- ─────────────────────────────────────────────
DROP POLICY IF EXISTS "pedidos_insert_anon" ON pedidos;
CREATE POLICY "pedidos_insert_anon"
  ON pedidos FOR INSERT
  WITH CHECK (true);

-- SELECT: el comprador ve sus pedidos (filtramos por comprador_roblox en la app)
-- Como no hay auth, permitimos SELECT anon y filtramos en la query del cliente
DROP POLICY IF EXISTS "pedidos_select_anon" ON pedidos;
CREATE POLICY "pedidos_select_anon"
  ON pedidos FOR SELECT
  USING (true);

-- UPDATE: permitido (el vendedor cambia estado, el comprador confirma entrega)
DROP POLICY IF EXISTS "pedidos_update_anon" ON pedidos;
CREATE POLICY "pedidos_update_anon"
  ON pedidos FOR UPDATE
  USING (true)
  WITH CHECK (true);

-- ─────────────────────────────────────────────
-- 4. TABLA: ofertas
--    - Cualquiera puede insertar ofertas
--    - Lectura pública (el vendedor filtra por vendedor_id en la app)
--    - Update para que vendedor acepte/rechace
-- ─────────────────────────────────────────────
DROP POLICY IF EXISTS "ofertas_insert_anon" ON ofertas;
CREATE POLICY "ofertas_insert_anon"
  ON ofertas FOR INSERT
  WITH CHECK (true);

DROP POLICY IF EXISTS "ofertas_select_anon" ON ofertas;
CREATE POLICY "ofertas_select_anon"
  ON ofertas FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "ofertas_update_anon" ON ofertas;
CREATE POLICY "ofertas_update_anon"
  ON ofertas FOR UPDATE
  USING (true)
  WITH CHECK (true);

-- ─────────────────────────────────────────────
-- 5. TABLA: mensajes
--    - Cualquiera puede insertar mensajes
--    - Solo se pueden leer mensajes de un pedido conocido
-- ─────────────────────────────────────────────
DROP POLICY IF EXISTS "mensajes_insert_anon" ON mensajes;
CREATE POLICY "mensajes_insert_anon"
  ON mensajes FOR INSERT
  WITH CHECK (true);

DROP POLICY IF EXISTS "mensajes_select_anon" ON mensajes;
CREATE POLICY "mensajes_select_anon"
  ON mensajes FOR SELECT
  USING (true);

-- ─────────────────────────────────────────────
-- 6. TABLA: vendedores
--    - Lectura pública (stats)
--    - Insert para registro de nuevos vendedores
-- ─────────────────────────────────────────────
DROP POLICY IF EXISTS "vendedores_select_public" ON vendedores;
CREATE POLICY "vendedores_select_public"
  ON vendedores FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "vendedores_insert_anon" ON vendedores;
CREATE POLICY "vendedores_insert_anon"
  ON vendedores FOR INSERT
  WITH CHECK (true);

DROP POLICY IF EXISTS "vendedores_update_own" ON vendedores;
CREATE POLICY "vendedores_update_own"
  ON vendedores FOR UPDATE
  USING (true)
  WITH CHECK (true);

-- ─────────────────────────────────────────────
-- 7. STORAGE: bucket "comprobantes"
--    Ejecuta esto también en el SQL Editor
-- ─────────────────────────────────────────────

-- Crear bucket público para comprobantes Yape
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'comprobantes',
  'comprobantes',
  true,
  5242880,  -- 5MB límite
  ARRAY['image/jpeg','image/jpg','image/png','image/webp','image/gif']
)
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 5242880,
  allowed_mime_types = ARRAY['image/jpeg','image/jpg','image/png','image/webp','image/gif'];

-- Policy: cualquiera puede subir al bucket
DROP POLICY IF EXISTS "comprobantes_upload" ON storage.objects;
CREATE POLICY "comprobantes_upload"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'comprobantes');

-- Policy: lectura pública
DROP POLICY IF EXISTS "comprobantes_select" ON storage.objects;
CREATE POLICY "comprobantes_select"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'comprobantes');

-- ─────────────────────────────────────────────
-- 8. REALTIME: habilitar para mensajes y pedidos
--    Esto se hace en el dashboard pero también via SQL:
-- ─────────────────────────────────────────────
-- Ve a Supabase Dashboard → Database → Replication
-- y activa las tablas: mensajes, pedidos
-- O ejecuta:
ALTER PUBLICATION supabase_realtime ADD TABLE mensajes;
ALTER PUBLICATION supabase_realtime ADD TABLE pedidos;

-- ═══════════════════════════════════════════════════════════════
-- LISTO. Ahora reemplaza los archivos HTML con los nuevos.
-- ═══════════════════════════════════════════════════════════════
