# macaroni

Resolve a MAC addresse to its manufacturer.

* Designed to be quick, compact and authoritative.

---
# Quick.

* No setup time: all data structures are staticly held in the BSS.
* The table is stored as a tree where each branch uses the most suitable data structure.

---

# Compact.

* 2.8MB on 32bit Linux and 3.8MB on 64bit MacOS.
* Strings are de-deplicated, and data structures are packed.

 
---

# Authoritative.

* resolves 28,372 MAC address prefixes.
* `manuf.txt` is drawn from the Wireshark project.

---

# Okay, .. but why?

* Sometimes knowing that you're communicating with the hardware you should be is useful.

