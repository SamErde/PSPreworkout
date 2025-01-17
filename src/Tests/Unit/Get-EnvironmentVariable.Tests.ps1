Describe 'Get-EnvironmentVariable' {
    It 'Should return the value of an existing environment variable' {
        # Arrange
        $env:TEST_VARIABLE = 'TestValue'

        # Act
        $result = Get-EnvironmentVariable -Name 'TEST_VARIABLE'

        # Assert
        $result[0].Value | Should -Be 'TestValue'

        # Cleanup
        Remove-Item -Path Env:TEST_VARIABLE
    }

    <#
    It 'Should return $null for a non-existing environment variable' {
        # Act
        $result = Get-EnvironmentVariable -Name 'NON_EXISTENT_VARIABLE'

        # Assert
        $result | Should -Be $null
    }
    #>
}
