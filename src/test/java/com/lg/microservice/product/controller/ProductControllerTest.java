package com.lg.microservice.product.controller;

import java.util.ArrayList;
import java.util.List;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.springframework.boot.test.context.SpringBootTest;
import com.lg.microservice.product.exception.RestCustomCode;
import com.lg.microservice.product.exception.RestCustomException;
import com.lg.microservice.product.feign.BuilderProductProcessLayerClient;
import com.lg.microservice.product.request.ProductRequest;
import com.lg.microservice.product.response.ProductExternal;
import com.lg.microservice.product.utils.StringUtil;
import com.lg.microservice.product.validator.Validator;

@SpringBootTest(classes = ProductControllerTest.class)
public class ProductControllerTest {

	private final String VALID_BUSINESS_UNITS = "CAC,BUILDER";
	private final String COMMA_SEPERATED_LARGE_STR = "STR1,STR2,STR3,STR4,STR5";
    private final String DATE_YYYY_MM_DD = "2023-10-23";
    private final String DATE_YYYY_DD_MM = "2023-23-10";
    
    @Mock
    private BuilderProductProcessLayerClient builderProductProcessLayerClient;
    
    @Mock
    private Validator validator;
    
    @InjectMocks
    private ProductController productController;
    
    @Test
    public void getProducts_ValidRequest_ReturnSuccess() {
        List<ProductExternal> expected = new ArrayList<>();
        List<String> strings = StringUtil.convertStringToArrayList(COMMA_SEPERATED_LARGE_STR);
        
        ProductRequest request = ProductRequest.of(strings, strings, DATE_YYYY_MM_DD);
        Mockito.when(builderProductProcessLayerClient.getBuilderProducts(request)).thenReturn(expected);
        
        List<String> businessUnits = StringUtil.convertStringToArrayList(VALID_BUSINESS_UNITS);
        Mockito.when(validator.validateBusinessUnits(businessUnits)).thenReturn(Boolean.TRUE);
        Mockito.when(validator.isValidDateFormat(DATE_YYYY_MM_DD)).thenReturn(Boolean.TRUE);
        
        List<ProductExternal> response = productController.getBuilderProducts(
        		VALID_BUSINESS_UNITS, 
        		COMMA_SEPERATED_LARGE_STR, 
        		COMMA_SEPERATED_LARGE_STR, 
        		DATE_YYYY_MM_DD);
       
        Assertions.assertEquals(response, expected);
        Mockito.verify(builderProductProcessLayerClient, Mockito.times(1)).getBuilderProducts(request);

    }

    @Test
    public void getProducts_invalidUpdateDateFormat_ReturnSuccess() {
        List<String> businessUnits = StringUtil.convertStringToArrayList(VALID_BUSINESS_UNITS);
        Mockito.when(validator.validateBusinessUnits(businessUnits)).thenReturn(Boolean.TRUE);
        Mockito.when(validator.isValidDateFormat(DATE_YYYY_MM_DD)).thenReturn(Boolean.FALSE);
        
        RestCustomException exception = Assertions.assertThrows(
        		RestCustomException.class,
                () -> productController.getBuilderProducts(
                		VALID_BUSINESS_UNITS, 
                		COMMA_SEPERATED_LARGE_STR, 
                		COMMA_SEPERATED_LARGE_STR, 
                		DATE_YYYY_DD_MM
                )
        );
        
        List<RestCustomCode> errors = exception.getCustomErrors();

        Assertions.assertEquals(errors.size(), 1);
        Assertions.assertEquals(errors.get(0).getErrorCode(), RestCustomCode.INVALID_DATE.getErrorCode());
        Assertions.assertEquals(errors.get(0).getMessage(), RestCustomCode.INVALID_DATE.getMessage());
    }
    
    @Test
    public void getProducts_invalidBusinessUnit_ReturnSuccess() {
        List<String> businessUnits = StringUtil.convertStringToArrayList(COMMA_SEPERATED_LARGE_STR);

        Mockito.when(validator.isValidDateFormat(DATE_YYYY_MM_DD)).thenReturn(Boolean.TRUE);
        Mockito.when(validator.validateBusinessUnits(businessUnits)).thenReturn(Boolean.FALSE);
        RestCustomException exception = Assertions.assertThrows(
        		RestCustomException.class,
                () -> productController.getBuilderProducts(
                		COMMA_SEPERATED_LARGE_STR,
                		COMMA_SEPERATED_LARGE_STR, 
                		COMMA_SEPERATED_LARGE_STR, 
                		DATE_YYYY_MM_DD
                )
        );
        
        List<RestCustomCode> errors = exception.getCustomErrors();

        Assertions.assertEquals(errors.size(), 1);
        Assertions.assertEquals(errors.get(0).getErrorCode(), RestCustomCode.BUSINESS_UNIT_INVALID.getErrorCode());
        Assertions.assertEquals(errors.get(0).getMessage(), RestCustomCode.BUSINESS_UNIT_INVALID.getMessage());
    }
}
