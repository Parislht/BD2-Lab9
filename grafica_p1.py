import matplotlib.pyplot as plt

tamanios = [10**2, 10**3, 10**4, 10**5, 10**6]

tiempo_con_indice = [0.140, 0.140, 6.194, 13.788, 82.399]
tiempo_sin_indice = [0.140, 1.007, 7.713, 95.438, 416.524]

plt.figure(figsize=(10, 6))

plt.plot(tamanios, tiempo_sin_indice, marker='o', label='Sin índice')
plt.plot(tamanios, tiempo_con_indice, marker='o', label='Con índice GIN')

plt.xscale('log')

plt.title('Comparación de rendimiento: Escaneo secuencial vs Índice GIN')
plt.xlabel('Número de registros')
plt.ylabel('Tiempo de ejecución (ms)')
plt.legend()
plt.grid(True, which='both', linestyle='--', linewidth=0.5)

plt.tight_layout()
plt.savefig('comparacion_gin_vs_secuencial.png', dpi=300)
plt.show()