let allWeps = window.yalAllWeapons;
if (allWeps == null) {
  let packs = game.packs.filter(p => p.metadata.type == "Item");
  let indexes = await Promise.all(packs.map(p => p.getIndex()));
  //
  let uuids = [];
  for (let pack of packs) for (let item of pack.index) if (item.type == "weapon") {
    uuids.push(item.uuid);
  }
  //
  let weps = [];
  for (let i = 0, n = uuids.length; i < n; i++) {
    let wep = await fromUuid(uuids[i]);
    console.log(i + "/" + n, wep);
    weps.push(wep);
  }
  console.log(weps);
  window.yalAllWeapons = allWeps = weps;
}
//
let weps = allWeps;
weps = weps.filter(wep => {
  let sys = wep.system;
  if (sys.level.value > 1) return false;
  if (sys.damage.die == null) return false;
  if (sys.category == "unarmed") return false;
  return true;
});
//
function traitMapper(t) {
  switch (t) {
    case "grippli": return "tripkee";
    case "gnoll": return "kholo";
    default: return t;
  }
}
weps = weps.map(wep => {
  let sys = wep.system;
  let reload = sys.reload?.value;
  return {
    name: wep.name,
    group: sys.group,
    category: sys.category,
    level: sys.level.value,
    damage: sys.damage.die,
    damageType: sys.damage.damageType,
    traits: sys.traits.value,
    rarity: wep.rarity,
    reload: reload == "-" ? 0 : parseInt(reload),
    range: sys.range,
    usage: sys.usage?.value,
  };
});
//
console.log(weps);
window.weps = weps;