import { listProducts } from "@lib/data/products"
import { HttpTypes } from "@medusajs/types"
import ProductActions from "@modules/products/components/product-actions"

/**
 * Fetches real time pricing for a product and renders the product actions component.
 */
export default async function ProductActionsWrapper({
  id,
  region,
}: {
  id: string
  region: HttpTypes.StoreRegion
}) {
  const product = await listProducts({
    queryParams: { fields: "*variants.calculated_price,+variants.inventory_quantity,+metadata,+tags" },
    regionId: region.id,
  }).then(({ response }) => response.products.find(p => p.id === id))

  if (!product) {
    return null
  }

  return <ProductActions product={product} region={region} />
}
