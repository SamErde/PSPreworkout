function Filter-EmptyProperty {
   $PropertiesWithValues = [Ordered]@{}
   foreach ($property in $_.PSObject.Properties) {
      if ($property.Value) {
         $hashtable[$property.Name] = $property.Value
      }
   }
   [PSCustomObject]$PropertiesWithValues
}
