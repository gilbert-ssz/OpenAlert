import { View, Text, TouchableOpacity, ScrollView, StyleSheet } from "react-native";
import { COLORS as C } from "../config";

const DOT = { alert: C.red, ok: C.green, info: C.muted };

export default function ActivityScreen({ sensor }) {
  const { triggered, log, acknowledge, silenceBuzzer } = sensor;

  return (
    <ScrollView style={s.page} contentContainerStyle={{ padding: 20 }}>
      <View style={s.header}>
        <Text style={s.title}>Activity log</Text>
        {triggered && <Text style={s.badge}>TRIGGERED</Text>}
      </View>

      {triggered && (
        <View style={s.alertCard}>
          <Text style={s.alertLabel}>Security alert</Text>
          <Text style={s.alertTitle}>DOOR OPEN</Text>
          <Text style={s.muted}>Your front door was opened — {log[0].time}</Text>
        </View>
      )}

      <Text style={s.label}>Timeline</Text>
      {log.map((item) => (
        <View key={item.id} style={s.item}>
          <View style={[s.dot, { backgroundColor: DOT[item.type] }]} />
          <View>
            <Text style={s.itemText}>{item.text}</Text>
            <Text style={s.muted}>Today, {item.time}</Text>
          </View>
        </View>
      ))}

      {triggered && (
        <>
          <TouchableOpacity style={s.red} onPress={acknowledge}>
            <Text style={s.redText}>Acknowledge alert</Text>
          </TouchableOpacity>
          <TouchableOpacity style={s.ghost} onPress={silenceBuzzer}>
            <Text style={s.ghostText}>Silence buzzer</Text>
          </TouchableOpacity>
        </>
      )}
    </ScrollView>
  );
}

const s = StyleSheet.create({
  page: { flex: 1 },
  header: { flexDirection: "row", justifyContent: "space-between", alignItems: "center", marginBottom: 20 },
  title: { color: C.text, fontSize: 20, fontWeight: "700" },
  badge: { color: C.red, borderColor: C.red, borderWidth: 1, borderRadius: 20, paddingHorizontal: 10, paddingVertical: 4, fontSize: 11, fontWeight: "700" },
  alertCard: { backgroundColor: C.card, borderColor: C.red, borderWidth: 1.5, borderRadius: 20, alignItems: "center", padding: 24, marginBottom: 20 },
  alertLabel: { color: C.red, fontSize: 12, fontWeight: "700" },
  alertTitle: { color: C.text, fontSize: 26, fontWeight: "800", marginVertical: 10 },
  label: { color: C.muted, fontSize: 12, marginBottom: 12 },
  item: { flexDirection: "row", gap: 12, marginBottom: 16 },
  dot: { width: 10, height: 10, borderRadius: 5, marginTop: 5 },
  itemText: { color: C.text, fontWeight: "600", fontSize: 14 },
  muted: { color: C.muted, fontSize: 12, marginTop: 2 },
  red: { backgroundColor: C.red, borderRadius: 12, padding: 16, alignItems: "center", marginTop: 12 },
  redText: { color: C.text, fontWeight: "700" },
  ghost: { borderColor: C.border, borderWidth: 1, borderRadius: 12, padding: 16, alignItems: "center", marginTop: 10 },
  ghostText: { color: C.muted, fontWeight: "600" },
});
