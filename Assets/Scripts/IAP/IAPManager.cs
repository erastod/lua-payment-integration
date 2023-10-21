using UnityEngine;
using UnityEngine.Purchasing;
using System;

public class IAPManager : IStoreListener
{
    private IStoreController controller;
    private IExtensionProvider extensions;
    private ConfigurationBuilder configBuilder;

    public Action<IStoreController, IExtensionProvider> OnInitializeAction;
    public Action<InitializationFailureReason> OnInitializationFailureAction;
    public Action<PurchaseEventArgs> OnPurchaseSuccessfulAction;
    public Action<Product, PurchaseFailureReason> OnPurchaseFailedAction;

    public IAPManager()
    {
        configBuilder = ConfigurationBuilder.Instance(StandardPurchasingModule.Instance());
        Debug.LogWarning("IAPManager created");
        IAPConfigurationHelper.PopulateConfigurationBuilder(ref configBuilder, ProductCatalog.LoadDefaultCatalog());
    }

    public void AddProduct(string productName, ProductType productType)
    {
        configBuilder.AddProduct(productName, productType, new IDs
        {
            { productName + "_google", GooglePlay.Name },
            { productName + "_mac", MacAppStore.Name }
        });
        Debug.LogWarning("Product Added: " + productName + ", " + productType.ToString());
    }

    public void Initialize()
    {
        Debug.LogWarning("Initialize() called: " + (((IStoreListener)this) == null));
        UnityPurchasing.Initialize(this, configBuilder);
    }

    public bool PurchaseProduct(string productID)
    {
        if (controller != null)
        {
            Product product = controller.products.WithID(productID);
            if (product != null && product.availableToPurchase)
            {
                controller.InitiatePurchase(product);
                return true;
            }
            else
            {
                Debug.LogWarning("Product not available for purchase.");
            }
        }
        else
        {
            Debug.LogWarning("IAPManager not initialized.");
        }
        return false;
    }

    public void OnInitialized(IStoreController controller, IExtensionProvider extensions)
    {
        this.controller = controller;
        this.extensions = extensions;

        if (OnInitializeAction != null)
        {
            OnInitializeAction.Invoke(controller, extensions);
        }
    }

    public void OnInitializeFailed(InitializationFailureReason error)
    {
        Debug.LogWarning("IAP Initialization failed, Reason: " + error);
        if (OnInitializationFailureAction != null)
        {
            OnInitializationFailureAction.Invoke(error);
        }
    }

    public PurchaseProcessingResult ProcessPurchase(PurchaseEventArgs e)
    {
        Debug.LogWarning(e);

        if (OnPurchaseSuccessfulAction != null)
        {
            OnPurchaseSuccessfulAction.Invoke(e);
        }

        var result = PurchaseProcessingResult.Complete;
        Debug.LogWarning(result);
        Debug.Log("Processing transaction: " + e.purchasedProduct.definition.id);
        Debug.Log("Receipt: " + e.purchasedProduct.receipt);
        return result;
    }

    public void OnPurchaseFailed(Product product, PurchaseFailureReason reason)
    {
        Debug.LogWarning("Product purchase failed: " + product.definition.id + ", Reason: " + reason);
        if (OnPurchaseFailedAction != null)
        {
            OnPurchaseFailedAction.Invoke(product, reason);
        }
    }
}
