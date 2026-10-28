-- ====================================================================
-- PROYECTO MODULAR: Zero KM — Seguridad colaborativa para el motociclista mexicano
-- SCRIPT INICIAL: 5 Tablas Core normalizadas a 3FN
-- Motor: PostgreSQL 16 con extensión espacial PostGIS
-- ====================================================================

CREATE TABLE usuario (
    id_usuario SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(120) UNIQUE NOT NULL,
    contrasena_hash VARCHAR(255) NOT NULL,
    nivel_experiencia VARCHAR(30) NOT NULL CHECK (nivel_experiencia IN ('Novato', 'Intermedio', 'Avanzado')),
    reputacion_score NUMERIC(3, 2) NOT NULL DEFAULT 5.00 CHECK (reputacion_score BETWEEN 0.00 AND 5.00),
    saldo_monedero NUMERIC(10, 2) NOT NULL DEFAULT 0.00 CHECK (saldo_monedero >= 0.00),
    fecha_registro DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE viaje (
    id_viaje SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    origen_latitud NUMERIC(10, 8) NOT NULL CHECK (origen_latitud BETWEEN -90.00000000 AND 90.00000000),
    origen_longitud NUMERIC(11, 8) NOT NULL CHECK (origen_longitud BETWEEN -180.00000000 AND 180.00000000),
    destino_latitud NUMERIC(10, 8) NOT NULL CHECK (destino_latitud BETWEEN -90.00000000 AND 90.00000000),
    destino_longitud NUMERIC(11, 8) NOT NULL CHECK (destino_longitud BETWEEN -180.00000000 AND 180.00000000),
    distancia_km NUMERIC(6, 2) NOT NULL CHECK (distancia_km > 0.00),
    duracion_segundos INT NOT NULL CHECK (duracion_segundos > 0),
    costo_casetas NUMERIC(10, 2) NOT NULL DEFAULT 0.00 CHECK (costo_casetas >= 0.00),
    fecha_creacion DATE NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT fk_viaje_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario) ON DELETE CASCADE
);

CREATE TABLE alerta_vial (
    id_alerta SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL,
    tipo_alerta VARCHAR(30) NOT NULL CHECK (tipo_alerta IN ('bache', 'curva_peligrosa', 'accidente', 'situacion_delictiva')),
    latitud NUMERIC(10, 8) NOT NULL CHECK (latitud BETWEEN -90.00000000 AND 90.00000000),
    longitud NUMERIC(11, 8) NOT NULL CHECK (longitud BETWEEN -180.00000000 AND 180.00000000),
    nivel_peligro INT NOT NULL CHECK (nivel_peligro BETWEEN 1 AND 5),
    estado_activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_reporte DATE NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT fk_alerta_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario) ON DELETE RESTRICT
);

CREATE TABLE punto_seguro (
    id_punto_seguro SERIAL PRIMARY KEY,
    nombre_lugar VARCHAR(120) NOT NULL,
    categoria VARCHAR(40) NOT NULL CHECK (categoria IN ('GASOLINERA', 'TALLER_MOTO', 'DESCANSO_PARADOR')),
    latitud NUMERIC(10, 8) NOT NULL CHECK (latitud BETWEEN -90.00000000 AND 90.00000000),
    longitud NUMERIC(11, 8) NOT NULL CHECK (longitud BETWEEN -180.00000000 AND 180.00000000),
    tarifa_auxilio NUMERIC(10, 2) DEFAULT 0.00 CHECK (tarifa_auxilio >= 0.00),
    validado_comunidad BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE detalle_parada_viaje (
    id_viaje INT NOT NULL,
    id_punto_seguro INT NOT NULL,
    tiempo_estancia_min INT NOT NULL CHECK (tiempo_estancia_min >= 0),
    motivo_parada VARCHAR(50) NOT NULL CHECK (motivo_parada IN ('combustible', 'descanso', 'reparacion', 'alimentos')),
    gasto_parada NUMERIC(10, 2) DEFAULT 0.00 CHECK (gasto_parada >= 0.00),
    fecha_parada DATE NOT NULL DEFAULT CURRENT_DATE,
    PRIMARY KEY (id_viaje, id_punto_seguro),
    CONSTRAINT fk_parada_viaje FOREIGN KEY (id_viaje)
        REFERENCES viaje(id_viaje) ON DELETE CASCADE,
    CONSTRAINT fk_parada_puntoseguro FOREIGN KEY (id_punto_seguro)
        REFERENCES punto_seguro(id_punto_seguro) ON DELETE RESTRICT
);

CREATE INDEX idx_alerta_coordenadas ON alerta_vial(latitud, longitud);
CREATE INDEX idx_puntoseguro_coordenadas ON punto_seguro(latitud, longitud);
