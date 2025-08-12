import { listProducts } from "@lib/data/products"
import { getRegion } from "@lib/data/regions"
import { HttpTypes } from "@medusajs/types"
import Product from "../product-preview"

type RelatedProductsProps = {
  product: HttpTypes.StoreProduct
  countryCode: string
}

export default async function RelatedProducts({
  product,
  countryCode,
}: RelatedProductsProps) {
  const region = await getRegion(countryCode)

  if (!region) {
    return null
  }

  // edit this function to define your related products logic
  const queryParams: HttpTypes.StoreProductListParams = {}
  if (region?.id) {
    queryParams.region_id = region.id
  }
  
  const products = await listProducts({
    queryParams,
    countryCode,
  }).then(({ response }) => {
    // Filter products after fetching
    let filtered = response.products.filter(
      (responseProduct) => responseProduct.id !== product.id
    )
    
    // Apply additional filters based on collection, tags, etc.
    if (product.collection_id) {
      filtered = filtered.filter(p => p.collection_id === product.collection_id)
    }
    
    if (product.tags && product.tags.length > 0) {
      const productTagIds = product.tags.map(t => t.id).filter(Boolean)
      if (productTagIds.length > 0) {
        filtered = filtered.filter(p => 
          p.tags?.some(tag => productTagIds.includes(tag.id))
        )
      }
    }
    
    // Filter out gift cards (assuming there's a metadata field or similar)
    filtered = filtered.filter(p => p.type_id !== 'gift-card')
    
    return filtered
  })

  if (!products.length) {
    return null
  }

  return (
    <div className="product-page-constraint">
      <div className="flex flex-col items-center text-center mb-16">
        <span className="text-base-regular text-gray-600 mb-6">
          Related products
        </span>
        <p className="text-2xl-regular text-ui-fg-base max-w-lg">
          You might also want to check out these products.
        </p>
      </div>

      <ul className="grid grid-cols-2 small:grid-cols-3 medium:grid-cols-4 gap-x-6 gap-y-8">
        {products.map((product) => (
          <li key={product.id}>
            <Product region={region} product={product} />
          </li>
        ))}
      </ul>
    </div>
  )
}
