package com.dailyfixer.dto;

import com.dailyfixer.model.Product;
import com.dailyfixer.model.Discount;

import java.util.List;
import java.util.Set;

/**
 * Data Transfer Object for Product Details page.
 * Contains all prepared data needed for the view layer.
 */
public class ProductDetailsData {
    private Product product;
    private List<VariantData> variants;
    private Set<String> colors;
    private Set<String> sizes;
    private Set<String> powers;
    private boolean hasVariants;
    private boolean outOfStock;
    private double originalPrice;
    private double displayPrice;
    private Discount activeDiscount;
    
    /**
     * Inner class to hold variant data with pricing information
     */
    public static class VariantData {
        private int id;
        private String color;
        private String size;
        private String power;
        private double price;
        private double displayPrice;
        private int quantity;
        private DiscountData discount;
        
        public VariantData() {}
        
        // Getters and Setters
        public int getId() { return id; }
        public void setId(int id) { this.id = id; }
        
        public String getColor() { return color; }
        public void setColor(String color) { this.color = color; }
        
        public String getSize() { return size; }
        public void setSize(String size) { this.size = size; }
        
        public String getPower() { return power; }
        public void setPower(String power) { this.power = power; }
        
        public double getPrice() { return price; }
        public void setPrice(double price) { this.price = price; }
        
        public double getDisplayPrice() { return displayPrice; }
        public void setDisplayPrice(double displayPrice) { this.displayPrice = displayPrice; }
        
        public int getQuantity() { return quantity; }
        public void setQuantity(int quantity) { this.quantity = quantity; }
        
        public DiscountData getDiscount() { return discount; }
        public void setDiscount(DiscountData discount) { this.discount = discount; }
    }
    
    /**
     * Inner class to hold discount data for JSON serialization
     */
    public static class DiscountData {
        private String name;
        private String type;
        private double value;
        private boolean isValid;
        
        public DiscountData() {}
        
        public DiscountData(Discount discount) {
            if (discount != null) {
                this.name = discount.getDiscountName() != null ? discount.getDiscountName() : "";
                this.type = discount.getDiscountType() != null ? discount.getDiscountType() : "";
                this.value = discount.getDiscountValue() != null ? discount.getDiscountValue().doubleValue() : 0;
                this.isValid = discount.isValid();
            }
        }
        
        // Getters and Setters
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        
        public String getType() { return type; }
        public void setType(String type) { this.type = type; }
        
        public double getValue() { return value; }
        public void setValue(double value) { this.value = value; }
        
        public boolean isValid() { return isValid; }
        public void setValid(boolean valid) { isValid = valid; }
    }
    
    // Main class Getters and Setters
    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }
    
    public List<VariantData> getVariants() { return variants; }
    public void setVariants(List<VariantData> variants) { this.variants = variants; }
    
    public Set<String> getColors() { return colors; }
    public void setColors(Set<String> colors) { this.colors = colors; }
    
    public Set<String> getSizes() { return sizes; }
    public void setSizes(Set<String> sizes) { this.sizes = sizes; }
    
    public Set<String> getPowers() { return powers; }
    public void setPowers(Set<String> powers) { this.powers = powers; }
    
    public boolean isHasVariants() { return hasVariants; }
    public void setHasVariants(boolean hasVariants) { this.hasVariants = hasVariants; }
    
    public boolean isOutOfStock() { return outOfStock; }
    public void setOutOfStock(boolean outOfStock) { this.outOfStock = outOfStock; }
    
    public double getOriginalPrice() { return originalPrice; }
    public void setOriginalPrice(double originalPrice) { this.originalPrice = originalPrice; }
    
    public double getDisplayPrice() { return displayPrice; }
    public void setDisplayPrice(double displayPrice) { this.displayPrice = displayPrice; }
    
    public Discount getActiveDiscount() { return activeDiscount; }
    public void setActiveDiscount(Discount activeDiscount) { this.activeDiscount = activeDiscount; }
}
