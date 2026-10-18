/// Medicines whose usable stock (active, in-date batches) is below their
/// reorder level, with their reminder state. Shared by the reorder list and
/// the alert planner so both always agree.
///
/// Variables: the day, as `YYYY-MM-DD`, for "not expired".
const belowLevelSql = '''
  SELECT m.id AS id,
         m.brand_name AS brand,
         m.strength AS strength,
         m.unit AS unit,
         m.reorder_level AS reorder_level,
         m.preferred_supplier_id AS supplier_id,
         COALESCE(u.usable, 0) AS usable,
         st.last_notified_on AS last_notified_on,
         st.snoozed_until AS snoozed_until
  FROM medicines m
  LEFT JOIN (
    SELECT medicine_id, SUM(quantity_on_hand) AS usable
    FROM batches
    WHERE deleted_at IS NULL AND status = 'ACTIVE'
      AND quantity_on_hand > 0 AND expiry_date >= ?
    GROUP BY medicine_id
  ) u ON u.medicine_id = m.id
  LEFT JOIN reorder_reminder_state st ON st.medicine_id = m.id
  WHERE m.deleted_at IS NULL
    AND m.is_archived = 0
    AND m.reorder_level > 0
    AND COALESCE(u.usable, 0) < m.reorder_level
''';
