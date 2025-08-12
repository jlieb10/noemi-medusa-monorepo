module.exports = {
  extends: ["next"],
  rules: {
    // Disable problematic Next.js rules
    "@next/next/no-html-link-for-pages": "off",
    "@next/next/no-page-custom-font": "off",
    "@next/next/no-typos": "off"
  }
};