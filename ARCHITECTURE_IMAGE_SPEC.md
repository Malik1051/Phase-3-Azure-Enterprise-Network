# Architecture Diagram — diagrams.net / Visio Recreation Spec

This specification describes a polished architecture diagram using **official Azure icon set** (available as a free stencil pack in both diagrams.net and Visio). Recommended canvas: **1600×1200px**, white or very light-gray (`#FAFAFA`) background, vertical top-to-bottom flow.

## Node Sequence (top → bottom)

1. **Internet** — cloud icon (generic "Internet" cloud symbol, not an Azure-specific icon), positioned at the very top, centered.
2. **Public IP** — Azure icon: *Public IP Address* (blue network category icon).
3. **Network Interface** — Azure icon: *Network Interface* (NIC icon, blue).
4. **Virtual Machine** — Azure icon: *Ubuntu / Linux Virtual Machine* (compute category, typically dark blue with the VM glyph).
5. **Virtual Network** — Azure icon: *Virtual Network* (hub icon), drawn as a large **container box** that visually wraps the three subnets below it, not just a single node in the chain.
6. **Three Subnets** (drawn side-by-side, inside the Virtual Network container):
   - Web Subnet
   - Application Subnet
   - Database Subnet
7. **Three NSGs** (drawn directly below/adjacent to their respective subnet, connected with a short line — not stacked in the main vertical flow):
   - Web NSG
   - Application NSG
   - Database NSG
8. **Azure Resource Group** — drawn as the **outermost container box**, encompassing the Virtual Network, all subnets, all NSGs, the NIC, and the Public IP (everything except the external Internet cloud).

## Visual Hierarchy

```
                     ┌── Internet (cloud icon) ──┐
                                  │
                          Public IP (icon)
                                  │
                        Network Interface (icon)
                                  │
                       Virtual Machine (icon)
                                  │
   ┌───────────── Virtual Network (container) ─────────────┐
   │   ┌──────────┐   ┌──────────────┐   ┌──────────────┐   │
   │   │   Web    │   │ Application  │   │   Database   │   │
   │   │  Subnet  │   │   Subnet     │   │   Subnet     │   │
   │   └────┬─────┘   └──────┬───────┘   └──────┬───────┘   │
   │        │                 │                   │           │
   │    Web NSG          App NSG              DB NSG          │
   └────────────────────────────────────────────────────────┘
   ┌──────────── Azure Resource Group (outer container) ───────┐
   │  (wraps everything above except Internet)                  │
   └─────────────────────────────────────────────────────────┘
```

## Azure Icon Set Details

- Use Microsoft's official **Azure Architecture Icons** package (SVG set, free download from the Azure Architecture Center) for diagrams.net or Visio.
- Category color conventions to follow (per Microsoft's own icon guidelines):
  - **Networking icons** (VNet, Subnet, NIC, Public IP, NSG) → blue family (`#0078D4` fill)
  - **Compute icons** (Virtual Machine) → dark blue/navy family
  - **Management/Groups** (Resource Group) → gray outline container, not a solid icon — Resource Groups are conventionally drawn as a labeled dashed or solid **bounding box**, not a discrete icon in the flow.

## Container/Grouping Rules

- **Resource Group**: outermost dashed-border rectangle, label in top-left corner of the box in small caps, light-gray fill (`#F3F2F1`) at low opacity so inner icons remain legible.
- **Virtual Network**: solid-border rectangle nested inside the Resource Group box, labeled top-left, slightly darker border than the Resource Group box to visually distinguish nesting level.
- **Subnets**: three equal-width rectangles arranged horizontally inside the VNet container, each with its own label and a thin connecting line down to its corresponding NSG icon just below/outside the VNet box.

## Connectors

- Use **orthogonal (right-angle) connectors**, not curved, for a clean enterprise-diagram look.
- Arrowheads point in the direction of traffic flow: `Internet → Public IP → NIC → VM` (inbound path), and thin non-arrowed lines from each Subnet down to its NSG (association relationship, not traffic flow).

## Typography & Style

- Labels: Segoe UI, 11–12pt, dark gray (`#323130`) text, centered under or beside each icon.
- Container labels: 10pt, bold, top-left corner of each bounding box.
- Consistent icon size: 48×48px for all resource icons; container boxes sized to comfortably fit their contents with ~24px internal padding.

## Export

- Export as PNG at 2x resolution and SVG (for crisp scaling in the README).
- Save both to `images/architecture-diagram.png` and reference in the README's [Screenshots](../README.md#-screenshots) section.
